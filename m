From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 10:22:42 +0200
Message-ID: <1233303762.26509.15.camel@lb-tlvb-eliezer>
References: <20090130065721.GA4886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Roland Dreier" <rdreier@cisco.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"aluno3@poczta.onet.pl" <aluno3@poczta.onet.pl>,
	"general@lists.openfabrics.org" <general@lists.openfabrics.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2530 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbZA3IYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 03:24:00 -0500
In-Reply-To: <20090130065721.GA4886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-29 at 22:57 -0800, Herbert Xu wrote:
> Roland Dreier <rdreier@cisco.com> wrote:
> > 
> > OK, thanks... what confused me is that several other drivers also do
> > skb_linearize() in their hard_start_xmit method... eg bnx2x,
> > via-velocity, mv643xx_eth.  So there are several other lurking bugs to
> > deal with here I guess.
> 
> I don't know about the rest but bnx2x is certainly OK since it
> only does so with IRQ enabled.  It is legal to call skb_linearize
> as long as you're sure that IRQs are enabled, which is always the
> case for hard_start_xmit upon entry.
> 
> So the only time you can't call it in hard_start_xmit is if you've
> just disabled IRQs yourself.
> 
Thanks Herbert,

That was my conclusion too and even though I was still looking at it
since this report yesterday - it still looks OK to me. The bnx2x is
getting into this flow when using SAMBA and it was tested on few systems
for days under traffic - this does not mean that the code is right and
it is not a prove that there is no bug - but it makes me feel better...

I would appreciate some comments if someone still thinks this is a bug.

Thanks,
Eilon


