From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] packet: avoid out of bounds read in round robin fanout
Date: Tue, 16 Jun 2015 17:51:53 -0400
Message-ID: <CA+FuTSdqdUxJab_zoQrYU7AJOnhceqOqhR_HCcpCaaJu55o8hQ@mail.gmail.com>
References: <1434488879-10663-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33285 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbFPVwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 17:52:24 -0400
Received: by oiyy130 with SMTP id y130so4376537oiy.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 14:52:24 -0700 (PDT)
In-Reply-To: <1434488879-10663-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 5:07 PM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> PACKET_FANOUT_LB computes f->rr_cur such that it is modulo
> f->num_members. It returns the old value unconditionally, but
> f->num_members may have changed since the last store. This can be
> fixed with
>
>   -        return cur
>   +        return cur < num ? : 0;

Well, that test is bad. Should be return cur < num ? cur : 0. But the
patch is more concise, anyway.

>
> When modifying the logic, simplify it further by replacing the loop
> with an unconditional atomic increment.
>
> Fixes: dc99f600698d ("packet: Add fanout support.")
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
