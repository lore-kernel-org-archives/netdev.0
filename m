From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 2 Feb 2011 06:40:02 +0200
Message-ID: <20110202044002.GB3818@redhat.com>
References: <20110128121616.GA8374@redhat.com>
 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
 <1296594585.26937.817.camel@localhost.localdomain>
 <20110201212411.GD30770@redhat.com>
 <1296595955.26937.822.camel@localhost.localdomain>
 <20110201214211.GB31105@redhat.com>
 <1296597185.26937.829.camel@localhost.localdomain>
 <20110201215603.GA31348@redhat.com>
 <1296601197.26937.833.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab1BBEkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 23:40:21 -0500
Content-Disposition: inline
In-Reply-To: <1296601197.26937.833.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 01, 2011 at 02:59:57PM -0800, Shirley Ma wrote:
> On Tue, 2011-02-01 at 23:56 +0200, Michael S. Tsirkin wrote:
> > There are flags for bytes, buffers and packets.
> > Try playing with any one of them :)
> > Just be sure to use v2.
> > 
> > 
> > >I would like to change it to
> > > half of the ring size instead for signaling. Is that OK?
> > > 
> > > Shirley
> > > 
> > > 
> > 
> > Sure that is why I made it a parameter so you can experiment. 
> 
> The initial test results shows that the CPUs utilization has been
> reduced some, and BW has increased some with the default parameters,
> like 1K message size BW goes from 2.5Gb/s about 2.8Gb/s, CPU utilization
> down from 4x% to 38%, (Similar results from the patch I submitted a
> while ago to reduce signaling on vhost) but far away from dropping
> packet results.
> 
> I am going to change the code to use 1/2 ring size to wake the netif
> queue.
> 
> Shirley

Just tweak the parameters with sysfs, you do not have to edit the code:
echo 64 > /sys/module/vhost_net/parameters/tx_bufs_coalesce

Or in a similar way for tx_packets_coalesce (since we use indirect,
packets will typically use 1 buffer each).

-- 
MST
