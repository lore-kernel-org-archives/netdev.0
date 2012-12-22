From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 10:15:21 +0100
Message-ID: <20121222101521.08c783ac@stein>
References: <50D49659.1000101@gmail.com>
	<50D4A219.7080807@linux-ipv6.org>
	<50D4ACFA.6040901@gmail.com>
	<50D4BD2F.7060006@linux-ipv6.org>
	<50D54ED9.6090908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:42896 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab2LVJPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 04:15:44 -0500
In-Reply-To: <50D54ED9.6090908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 22 Stephan Gatzka wrote:
> 
> > Something like this:
> >
> >   static inline int ndisc_opt_addr_space(struct net_device *dev)
> >   {
> > -       return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> > +       switch (dev->type) {
> > +       case ARPHRD_IEEE1394:
> > +               return sizeof(struct ndisc_opt_ieee1394_llinfo);
> > +       default:
> > +               return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> > +       }
> >   }
> >
> > --yoshfuji
> >
> 
> O.k., this has the advantage that only ndisc packets get some more 
> memory, but the question is if we are under such a hard memory pressure 
> that we don't allow that.
> 
> Your solution has the disadvantage that now I have to publish struct 
> ndisc_opt_ieee1394_llinfo to the ndisc stuff. Nobody in ndisc.c really 
> wants to deal with that structure, only the size is of interest. So 
> keeping this struct private is less invasive to the rest of linux. Just 
> my two cents.

You could add another case to include/net/ndisc.h::ndisc_addr_option_pad()
with a hardcoded size, couldn't you?
-- 
Stefan Richter
-=====-===-- ==-- =-==-
http://arcgraph.de/sr/
