From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Fri, 12 May 2006 10:40:47 -0700 (PDT)
Message-ID: <20060512.104047.37111282.davem@davemloft.net>
References: <20060510231347.GC25334@electric-eye.fr.zoreil.com>
	<4463CE88.20301@myri.com>
	<20060512064710.GA27065@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29064
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932168AbWELRkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 13:40:53 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060512064710.GA27065@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 12 May 2006 10:47:11 +0400

> On Fri, May 12, 2006 at 01:53:44AM +0200, Brice Goglin (brice@myri.com) wrote:
> > > Imho you will want to work directly with pages shortly.
> > >   
> > 
> > We had thought about doing this, but were a little nervous since we did
> > not know of any other drivers that worked directly with pages.  If this
> > is an official direction to work directly with pages, we will. 
> 
> s2io does. e1000 does it with skb frags.
> If your hardware allows header split and driver can put headers into
> skb->data and real data into frag_list, that allows to create various
> interesting things like receiving zero-copy support and netchannels
> support. It is work in progress, not official direction currently,
> but this definitely will help your driver to support future high 
> performance extensions.

The most important impact is not having to use order 1 pages
for jumbo MTU frames, which are more likely to fail allocations
thant order 0 pages under heavy load.
