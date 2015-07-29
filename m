From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Wed, 29 Jul 2015 02:05:33 -0400
Message-ID: <CA+FuTSfw+-6Xb_0xchM5E6vCMSsyiSvSYF3MbuE25pEt07RRbw@mail.gmail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com>
 <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com>
 <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com> <CAFBinCDZDYJGjimsAD=+HFokc9ga0cLBD1KSAieagzWQNH+s=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, johann.baudy@gnu-log.net
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36782 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbG2GGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:06:03 -0400
Received: by ykay190 with SMTP id y190so114727822yka.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 23:06:03 -0700 (PDT)
In-Reply-To: <CAFBinCDZDYJGjimsAD=+HFokc9ga0cLBD1KSAieagzWQNH+s=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2015 at 6:35 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> Hi Johann,
>
> On Tue, Jul 21, 2015 at 6:51 PM, Willem de Bruijn <willemb@google.com> wrote:
>> I don't see a simple way of verifying the safety of allowing packets
>> without data short of a code audit, which would be huge, especially
>> when taking device driver logic into account. Perhaps someone
>> remembers why that statement was added and what edge case(s)
>> it refers to. I'm afraid that I don't. It was added in 69e3c75f4d54. I
>> added the author to this thread.
> I know it's summer (and thus vacation-time), but did you already have
> a chance to look into this?

Martin, to return to your initial statement that PPPoE PADI packets can
have a zero payload: the PPPoE RFC states that PADI packets "MUST
contain exactly one TAG of TAG_TYPE Service-Name, indicating the
service the Host is requesting, and any number of other TAG types."
(RFC 2516, 5.1). Is the observed behavior (no payload) perhaps
incorrect?

Even if it is, if this is breaking established userspace expectations,
we should look into it. Ethernet specifies a minimum payload size of
46 on the wire, but perhaps that is handled with padding, so that
0 length should be valid within the stack. Also, there may be other
valid uses of 0 length payload on top of link layers that are not Ethernet.

>
> Regards,
> Martin
