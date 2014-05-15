From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Thu, 15 May 2014 09:16:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17246334@AcuExch.aculab.com>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141748.20309.83121.stgit@dragon>	<537399C2.8070908@intel.com>
	<20140514.134950.1208688313542719676.davem@davemloft.net>
 <20140514210935.5fc80c79@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"fw@strlen.de" <fw@strlen.de>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"robert@herjulf.se" <robert@herjulf.se>,
	"greearb@candelatech.com" <greearb@candelatech.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"danieltt@kth.se" <danieltt@kth.se>,
	"zhouzhouyi@gmail.com" <zhouzhouyi@gmail.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58739 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752556AbaEOJRK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:17:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12829-04 for <netdev@vger.kernel.org>;
 Thu, 15 May 2014 10:17:00 +0100 (BST)
In-Reply-To: <20140514210935.5fc80c79@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer
> On Wed, 14 May 2014 13:49:50 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > Date: Wed, 14 May 2014 09:28:50 -0700
> >
> > > I'd say that it might be better to just add a note to the documentation
> > > folder indicating what configuration is optimal for pktgen rather then
> > > changing everyone's defaults to support one specific test.
> >
> > We could have drivers provide a pktgen config adjustment mechanism,
> > so if someone starts pktgen then the device auto-adjusts to a pktgen
> > optimal configuration (whatever that may entail).
> 
> That might be problematic because changing the TX queue size cause the
> ixgbe driver to reset the link.
> 
> Notice that pktgen is ignoring BQL.  I'm sort of hoping that BQL will
> push back for real use-cases, to avoid the bad effects of increasing
> the TX size.
> 
> One of the bad effects, I'm hoping BQL will mitigate, is the case of
> filling the TX queue with large frames.  Consider 9K jumbo frames, how
> long time will it take to empty 1024 jumbo frames on a 10G link:
> 
> (9000*8)/(10000*10^6)*1000*1024 = 7.37ms

Never mind 9k 'jumbo' frames, I'm pretty sure ixgbe supports TCP segmentation
offload - so you can have 64k frames in the tx ring.
Since each takes (about) 44 ethernet frames that is about 55ms
to clear the queue.

	David
