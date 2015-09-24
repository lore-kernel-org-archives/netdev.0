From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Thu, 24 Sep 2015 14:05:25 -0700
Message-ID: <20150924140525.514eac85@urahara>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35831 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbIXVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:05:16 -0400
Received: by pacfv12 with SMTP id fv12so84648093pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 14:05:15 -0700 (PDT)
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 13:59:26 -0700
sfeldma@gmail.com wrote:

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


Rather than having more in bridge, shouldn't this just be a netlink event?
