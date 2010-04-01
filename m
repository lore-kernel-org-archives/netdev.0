From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Wed, 31 Mar 2010 17:24:01 -0700 (PDT)
Message-ID: <20100331.172401.00333850.davem@davemloft.net>
References: <20100330141904.5236fe44@nehalam>
	<20100330.225042.107712654.davem@davemloft.net>
	<4BB3E689.4050001@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755628Ab0DAAYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:24:00 -0400
In-Reply-To: <4BB3E689.4050001@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Wed, 31 Mar 2010 17:19:21 -0700

> So, I propose getting rid of 3-4 of these files that are of lesser
> value and moving the rest to debugfs for now.  If some alternative
> through ethtool or something becomes available I can get rid of
> anything that can be handled through a more general facility.  Would
> that be acceptable?

You can use sysfs.

I have a similar issue on NIU wherein a top-level set of logic
behaves like a parent virtual device and contains attributes
I'd like to export.

I create a dummy platform device to represent this node and
hang the device sysfs information in that device's sysfs
directory.  It shows up as /sys/devices/platform/niu.%d
and the network ports underneath this parent appear as
symlinks named "port%d"  (part of this is setup in
drivers/net/niu.c:niu_get_parent() and niu_new_parent())

You could do something similar to represent the fact that
these statistics are virtualized and belong to some centralized
virtual entity that represents one or more actual device ports.
