From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next] net: xfrm: support setting an output mark.
Date: Thu, 10 Aug 2017 02:13:15 +0900
Message-ID: <CAKD1Yr0FPo_ZAyjgFPg2CzNJiMMdUSx4PwwtL=ArPGeKHuTQ5w@mail.gmail.com>
References: <20170807092326.10239-1-lorenzo@google.com> <20170807111623.GQ2631@secunet.com>
 <CAKD1Yr2YXYed+vVgcyYo4XLAFXGjwwdSRucOmg+z2PVZD_A06Q@mail.gmail.com> <20170808075143.GR2631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Nathan Harold <nharold@google.com>,
        Jonathan Basseri <misterikkit@google.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35748 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753370AbdHIRNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 13:13:36 -0400
Received: by mail-yw0-f169.google.com with SMTP id l82so43877146ywc.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 10:13:36 -0700 (PDT)
In-Reply-To: <20170808075143.GR2631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 4:51 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> I thought you can just split the 32 bit mark into two 16 bit marks
> by setting an appropriate mask at the xfrm and the routing mark.
> But this has the drawback that the socket needs to know how possibly
> tunneled packets should be routed.

Right. And if those bits are already used for something else (e.g.,
Android uses something like 20 bits for marks) then that's not
possible.

Also - the other approach of using the SA mark for routing the
tunneled packet, that has backwards compatibility issues. If someone
is using mark-based routing, and has configured an SA with a mark,
then making the mark influence the routing lookup would change how
those tunnels are routed and possibly break them.

> So we transform the packet and may 'transform' the mark on the packet
> too. This could make sense, but we have to point out the differences
> between the xfrm_mark and the output_mark on the SA very explicit.

Ack. Where should this be pointed out? I've sent out a non-RFC version
to netdev, mostly unchanged but including a fair bit more rationale in
the commit message:

https://patchwork.ozlabs.org/patch/799891/

Or did you mean it should be be documented this in the ip-xfrm man page, or...?
