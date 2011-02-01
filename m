From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 13:53:05 -0800
Message-ID: <1296597185.26937.829.camel@localhost.localdomain>
References: <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
	 <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46478 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab1BAVxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 16:53:09 -0500
In-Reply-To: <20110201214211.GB31105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-01 at 23:42 +0200, Michael S. Tsirkin wrote:
> On Tue, Feb 01, 2011 at 01:32:35PM -0800, Shirley Ma wrote:
> > On Tue, 2011-02-01 at 23:24 +0200, Michael S. Tsirkin wrote:
> > > My theory is that the issue is not signalling.
> > > Rather, our queue fills up, then host handles
> > > one packet and sends an interrupt, and we
> > > immediately wake the queue. So the vq
> > > once it gets full, stays full.
> > 
> > >From the printk debugging output, it might not be exactly the case.
> The
> > ring gets full, run a bit, then gets full, then run a bit, then
> full...
> 
> Yes, but does it get even half empty in between?

Sometimes, most of them not half of empty in between. But printk slow
down the traffics, so it's not accurate. I think your patch will improve
the performance if it signals guest when half of the ring size is
empty. 

But you manage signal by using TX bytes, I would like to change it to
half of the ring size instead for signaling. Is that OK?

Shirley



