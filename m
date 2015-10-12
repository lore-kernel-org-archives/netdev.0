From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] switchdev: push bridge ageing_time
 attribute down
Date: Mon, 12 Oct 2015 05:20:47 -0700 (PDT)
Message-ID: <20151012.052047.1656215111847287382.davem@davemloft.net>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:36119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbbJLMEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:04:53 -0400
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu,  8 Oct 2015 19:23:16 -0700

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
> 
> v2->v3: Per Jiri review: push only ageing_time attr down at this time, and
> don't pass raw bridge IFLA_BR_* values; rather use new switchdev attr ID for
> ageing_time.
> 
> v1->v2: rebase w/ net-next

Series applied, thanks.
