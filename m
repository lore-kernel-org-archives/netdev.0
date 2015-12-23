From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 16:39:36 +0100
Message-ID: <1450885176.4301.36.camel@redhat.com>
References: <c891d011ef98267cd72157a5b01c78347ada8d8e.1450883640.git.pabeni@redhat.com>
	 <567ABF31.8080306@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>, Jesse Gross <jesse@nicira.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262AbbLWPjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 10:39:40 -0500
In-Reply-To: <567ABF31.8080306@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-23 at 16:35 +0100, Hannes Frederic Sowa wrote:
> On 23.12.2015 16:21, Paolo Abeni wrote:
> > @@ -1187,6 +1187,14 @@ static int geneve_configure(struct net *net, struct net_device *dev,
> >  	if (t)
> >  		return -EBUSY;
> >  
> > +	/* make enough headroom for basic scenario */
> > +	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
> > +	if (remote->sa.sa_family == AF_INET)
> > +		encap_len += sizeof(struct iphdr);
> > +	else
> > +		encap_len += sizeof(struct ipv6hdr);
> > +	dev->needed_headroom = encap_len;
> > +
> 
> We are missing one time ETH_HLEN or hard_header_len of the lower_dev (if
> available) in here AFAIK.

You are right. Most probably performance numbers where good even with
the missing ETH_HLEN due to some rounding. I'll send a v2.

Paolo
