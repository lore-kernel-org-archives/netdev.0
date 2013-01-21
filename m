From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 1/3] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Mon, 21 Jan 2013 07:43:26 +0100
Message-ID: <20130121064326.GA30530@secunet.com>
References: <50D1CECE.7090706@oktetlabs.ru>
 <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
 <20121220073445.GM18940@secunet.com>
 <50D2F4E5.4050904@oktetlabs.ru>
 <20121220123535.GN18940@secunet.com>
 <20121221102253.GO18940@secunet.com>
 <50F3C153.9030204@oktetlabs.ru>
 <20130118081145.GB24987@secunet.com>
 <20130118081419.GC24987@secunet.com>
 <alpine.LFD.2.00.1301190031080.1803@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40951 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811Ab3AUGn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 01:43:29 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1301190031080.1803@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 19, 2013 at 02:54:04AM +0200, Julian Anastasov wrote:
> > +
> > +void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
> > +{
> > +	const struct iphdr *iph = (const struct iphdr *) skb->data;
> > +	struct flowi4 fl4;
> > +	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
> 
> 	I guess __sk_dst_get should be called after
> bh_lock_sock ?

Yes, absolutely. I'll fix it before I submit the patch.

Thanks for your review!
