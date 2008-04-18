From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net/core: API to create/destroy /sys/class/net
 entries
Date: Thu, 17 Apr 2008 23:36:44 -0700 (PDT)
Message-ID: <20080417.233644.19783833.davem@davemloft.net>
References: <14079.1208394386@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbYDRGgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:36:46 -0400
In-Reply-To: <14079.1208394386@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 16 Apr 2008 18:06:26 -0700

> 	Bonding creates a file in sysfs, /sys/class/net/bonding_masters,
> which is used to create and destroy bonding devices.  Currently, when
> bonding is loaded, it does some poking through the device structure of
> the first bonding device to find the net_class, and then uses that
> pointer to create the file (by calling class_create_file).

As Stephen stated this was a horrible decision, that directory is for
network device instances, that's why the class variable is called
"netdev_class" not "dump_all_yer_networking_shit_here_class"

The only saving grace is that bonding creates a file, not a
directory, so "scan for all directories under /sys/class/net/"
schemes still work.

Water under the bridge I suppose, and we're stuck with this.

I guess your proposal is the best, as if we export netdev_class
people can do other funky, undesirable, things with it.

Please submit the final version of your patch, I'll apply it.
