From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/core: use net_device dev_id to indicate port number
Date: Wed, 26 May 2010 08:33:18 -0700
Message-ID: <20100526083318.5b7b7704@nehalam>
References: <20100526095200.GA7370@mtldesk030.lab.mtl.com>
	<20100526082306.25959fb6@nehalam>
	<20100526152730.GA10890@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rdreier@cisco.com, yevgenyp@mellanox.co.il
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675Ab0EZPdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 11:33:25 -0400
In-Reply-To: <20100526152730.GA10890@mtldesk030.lab.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 May 2010 18:27:30 +0300
Eli Cohen <eli@dev.mellanox.co.il> wrote:

> On Wed, May 26, 2010 at 08:23:06AM -0700, Stephen Hemminger wrote:
> > On Wed, 26 May 2010 12:52:00 +0300
> > Eli Cohen <eli@mellanox.co.il> wrote:
> > 
> > > Today, there are no means to know which port of a hardware device a netdev
> > > interface uses. struct net_device conatins a field, dev_id, that can be used
> > > for that. This patch adds a new macro, SET_NETDEV_DEV_ID(), to provide a
> > > standard way to set the value of this field.
> > > Also also make use of this feature in the mlx4_en driver to set the port
> > > number; port numbers are zero based.
> > 
> > Why is a macro wrapper needed?
> > 
> 
> I guess for the same reason we use SET_NETDEV_DEV - to provide a
> consistent interface for setting this value...

SET_NETDEV_DEV macro exists because at the time 2.5 kernel was being developed
it was important to be able to maintain source compatibility between 2.4 and
2.6 (nee 2.5) drivers. Since 2.4 did not have sysfs, the macro was a mechanism
to allow the same code to run on both kernel versions.

Your situation is different, just use dev_id and update documentation if
you need to.

-- 
