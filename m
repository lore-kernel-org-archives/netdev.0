From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Tue, 21 Jul 2015 12:28:44 -0400
Message-ID: <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, mostrows@earthlink.net
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34142 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084AbbGUQ3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 12:29:14 -0400
Received: by ykax123 with SMTP id x123so170607272yka.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 09:29:14 -0700 (PDT)
In-Reply-To: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 12:14 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> 9c70776 added validation for the packet size in packet_snd. This change
> enforced that every packet needs a long enough header and at least one
> byte payload.
>
> However, when trying to establish a PPPoE connection the following message
> is printed every time a PPPoE discovery packet is sent:
> pppd: packet size is too short (24 <= 24)
>
> From what I can see in the PPPoE code the "PADI" discovery packet can
> consist of only a header with no payload (when there is neither a service
> name nor a Host-Uniq configured).

Interesting. 9c7077622dd9 only extended the check from tpacket_snd to
packet_snd to make the two paths equivalent. The existing check had the
ominous statement

    /* net device doesn't like empty head */

so allowing a header-only packet while correct in your case may not be
safe in some edge cases (specific device drivers?).

This was also discussed previously

  http://www.spinics.net/lists/netdev/msg309677.html

In any case, I don't think that reverting the patch and restoring the old
inconsistent state is a fix.
