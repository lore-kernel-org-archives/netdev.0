From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code.
Date: Wed, 26 Mar 2008 10:46:26 +0300
Message-ID: <1206517586.20894.3.camel@iris.sw.ru>
References: <47E91CD0.8000901@openvz.org>
	 <20080326033200.GA31748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24033 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757513AbYCZHqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 03:46:15 -0400
In-Reply-To: <20080326033200.GA31748@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-03-26 at 11:32 +0800, Herbert Xu wrote:
> On Tue, Mar 25, 2008 at 06:40:00PM +0300, Pavel Emelyanov wrote:
> > Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
> > relookup support) introduced some dst leaks on error paths: the rt
> > pointer can be forgotten to be put. Fix it bu going to a proper label.
> > 
> > Found after net namespace's lo refused to unregister :) Many thanks to 
> > Den for valuable help during debugging.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Thanks for catching this!
> 
> > diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> > index ff9a8e6..db231cb 100644
> > --- a/net/ipv4/icmp.c
> > +++ b/net/ipv4/icmp.c
> > @@ -594,11 +594,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
> >  			rt = NULL;
> >  			break;
> >  		default:
> > -			goto out_unlock;
> > +			goto ende;
> >  		}
> 
> I'm not sure about this bit though because xfrm_lookup is meant
> to free the route on error.

This is not a problem, it assigns NULL in this case to a pointer.

