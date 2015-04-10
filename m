From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Fri, 10 Apr 2015 15:11:19 +0200
Message-ID: <1428671479.1890.23.camel@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
	 <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
	 <5527C877.6040700@cogentembedded.com>
	 (sfid-20150410_145653_908330_C14391BB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59293 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174AbbDJNLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 09:11:22 -0400
In-Reply-To: <5527C877.6040700@cogentembedded.com> (sfid-20150410_145653_908330_C14391BB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 15:56 +0300, Sergei Shtylyov wrote:

> > diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> > index 5f5c674e130a..5487d5e5191e 100644
> > --- a/net/ipv4/arp.c
> > +++ b/net/ipv4/arp.c
> > @@ -715,6 +715,14 @@ static int arp_process(struct sk_buff *skb)
> >   	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
> >   		goto out;
> >
> > + /*
> > +  *	For some 802.11 wireless deployments (and possibly other networks),
> > +  *	there will be an ARP proxy and gratuitous ARP frames are attacks
> > +  *	and thus should not be accepted.
> > +  */
> 
>     Hm, why this strange indentation?
> 
> > +	if (IN_DEV_CONF_GET(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
> > +		goto out;
> > +
> >   /*
> >    *     Special case: We must set Frame Relay source Q.922 address
> >    */
> [...]

Well, because of the context. All the comments in this file are that
way, so it seemed nicer to keep it like that rather than add one
"modern" one to it...

johannes
