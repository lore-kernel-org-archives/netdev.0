From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Mon, 28 Sep 2015 22:07:15 -0700 (PDT)
Message-ID: <20150928.220715.1323851557788272372.davem@davemloft.net>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbI2FHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:07:17 -0400
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 24 Sep 2015 13:59:26 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Push bridge-level attributes down to switchdev drivers.  This patchset
> adds the infrastructure and then pushes, as an example, ageing_time attribute
> down from bridge to switchdev (rocker) driver.  Add some range-checking
> for ageing_time.
> 
> # ip link set dev br0 type bridge ageing_time 1000
> 
> # ip link set dev br0 type bridge ageing_time 999
> RTNETLINK answers: Numerical result out of range
> 
> Up until now, switchdev attrs where port-level attrs, so the netdev used in
> switchdev_attr_set() would be a switch port or bond of switch ports.  With
> bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
> netdev.  The same recusive algo is used to visit the leaves of the stacked
> drivers to set the attr, it's just in this case we start one layer higher in
> the stack.  One note is not all ports in the bridge may support setting a
> bridge-level attribute, so rather than failing the entire set, we'll skip over
> those ports returning -EOPNOTSUPP.

This doesn't apply cleanly to net-next, please respin.

Thanks.
