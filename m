From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only
 require the I bit to be set
Date: Fri, 11 Jul 2014 22:28:11 +0100
Message-ID: <20140711212811.GG13525@casper.infradead.org>
References: <cover.1405097440.git.tgraf@suug.ch>
 <cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
 <20140711124126.262c2876@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, therbert@google.com,
	nicolas.dichtel@6wind.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, ogerlitz@mellanox.com,
	dborkman@redhat.com,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42914 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaGKV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 17:28:15 -0400
Content-Disposition: inline
In-Reply-To: <20140711124126.262c2876@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/14 at 12:41pm, Stephen Hemminger wrote:
> On Fri, 11 Jul 2014 18:59:49 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > @@ -1617,7 +1646,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
> >  	}
> >  
> >  	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> > -	vxh->vx_flags = htonl(VXLAN_FLAGS);
> > +	vxlan_flags(vxh) = VXLAN_FLAG_VNI;
> > +	vxh->vx_reserved1 = 0;
> > +	vxh->vx_reserved2 = 0;
> >  	vxh->vx_vni = vni;
> >  
>  
> Okay, but initializing bitfields generates crappy code.
> Can we just alias and do one assignment.

Sure, I'll resend.
