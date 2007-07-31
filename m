From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 31 Jul 2007 14:08:15 +0300
Message-ID: <200707311408.15231.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707311339.39913.joakim.koskela@hiit.fi> <46AF143E.9080709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:54266 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754137AbXGaLHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 07:07:15 -0400
In-Reply-To: <46AF143E.9080709@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 31 July 2007 13:51:42 Patrick McHardy wrote:
> Joakim Koskela wrote:
> > I'm not sure I really got this. IPv6/IPv4 means IPv6 inner, IPv4 outer,
> > right? Isn't that called from xfrm4_output_one and subsequently passed
> > through the right filters as well (as it has a ipv4 header by then)?
>
> I think you're right, it uses xfrm4_output. But there's a mismatch
> in either case, in both cases (IPv4 and IPv6) we first call the
> POSTROUTING hook for this family, than do the transform (changing
> the family), then call the OUTPUT hook for the same family. So
> either the POSTROUTING or the OUTPUT hook is called for the wrong
> family.

Ok, so changing int xfrm[46]_output(struct sk_buff*) to use the right PF & 
hook based on the skb's [current] family should put things through the right 
hoops, right?

br, j
