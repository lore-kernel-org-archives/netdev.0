From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 19:30:34 +0200
Message-ID: <20100915173034.GB2612@redhat.com>
References: <1284490143.13351.82.camel@localhost.localdomain>
 <20100914190156.GA16037@redhat.com>
 <1284492983.13351.95.camel@localhost.localdomain>
 <20100915051241.GA25340@redhat.com>
 <1284531675.24603.259.camel@localhost.localdomain>
 <20100915101000.GB28016@redhat.com>
 <1284562354.2573.12.camel@localhost.localdomain>
 <20100915150412.GA679@redhat.com>
 <20100915153927.GA1065@redhat.com>
 <1284570004.2573.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab0IORgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 13:36:46 -0400
Content-Disposition: inline
In-Reply-To: <1284570004.2573.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 10:00:04AM -0700, Shirley Ma wrote:
> On Wed, 2010-09-15 at 17:39 +0200, Michael S. Tsirkin wrote:
> > In fact, I rechecked: both bridge and loopback have NETIF_F_HIGHDMA
> > set.
> > So maybe we should check NETIF_F_NETNS_LOCAL ...
> > 
> > macvtap in bridged mode is interesting as well. 
> 
> I found that too, just wondered which flag to use is better. :)
> 
> Thanks
> Shirley

At some level NETIF_F_NETNS_LOCAL makes sense: local packets
can get anywhere. OTOH one wonders whether there might be other
issues, e.g. in theory devices could hang on to frag pages
just by doing get_page.  There might be other issues.
Maybe we are better off white-listing known-good drivers
with a new flag?

-- 
MST
