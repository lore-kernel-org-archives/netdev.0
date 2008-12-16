From: David Miller <davem@davemloft.net>
Subject: Re: net: RFC ethtool 5-tuple filter set/get feature
Date: Mon, 15 Dec 2008 22:50:13 -0800 (PST)
Message-ID: <20081215.225013.248487837.davem@davemloft.net>
References: <Pine.WNT.4.64.0812151630570.10472@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Santwona.Behera@Sun.COM,
	Matheos.Worku@Sun.COM
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbYLPGuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 01:50:12 -0500
In-Reply-To: <Pine.WNT.4.64.0812151630570.10472@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 15 Dec 2008 18:52:07 -0800 (Pacific Standard Time)

> I am looking at current methods to support adding 5-tuple filters to a 
> network device.  3 methods I can see are 1) Creating a sysfs interface, 2) 
> writing a custom application using netlink or some other interface, or 3) 
> Adding support to ethtool.

I'm pretty sure ethtool is the best mechanism currently.

> The latest ethtool bits support the rxhash callbacks, allowing different 
> Rx hashing methods to be enabled or disabled in Sun's Neptune device.  I 
> would like to add similar options to ethtool to support features in 
> current versions of igb hardware, and in future ixgbe hardware.

You could extend the existing RXHASH ethtool thing, adding your
key specifiers and some capability flags.

Actually, the Neptune folks (Santwona and Matheos CC:'d) are working
on ethtool interfaces to load TCAM entries, which would specify the
same things (except be a lot more flexible, multiple entries can be
loaded into Neptune, up to 128 or 256, with all kinds of masking etc.)

We could represent igb/ixgbe as a TCAM with one entry and no
masking support.  Or something like that.

You can find their proposal by looking for "Interface proposal for rx
classification using ethtool" subject in the netdev archives for
September 2008.  I believe it was posted on the 29th.
