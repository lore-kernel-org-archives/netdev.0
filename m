From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 22:05:48 -0800
Message-ID: <1296626748.26937.852.camel@localhost.localdomain>
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
	 <20110202044002.GB3818@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:55097 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab1BBGGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 01:06:03 -0500
In-Reply-To: <20110202044002.GB3818@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-02 at 06:40 +0200, Michael S. Tsirkin wrote:
> ust tweak the parameters with sysfs, you do not have to edit the code:
> echo 64 > /sys/module/vhost_net/parameters/tx_bufs_coalesce
> 
> Or in a similar way for tx_packets_coalesce (since we use indirect,
> packets will typically use 1 buffer each).

We should use packets instead of buffers, in indirect case, one packet
has multiple buffers, each packet uses one descriptor from the ring
(default size is 256).

echo 128 > /sys/module/vhost_net/parameters/tx_packets_coalesce

The way I am changing is only when netif queue has stopped, then we
start to count num_free descriptors to send the signal to wake netif
queue.

Shirley

