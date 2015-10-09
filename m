From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 0/4] switchdev: push bridge ageing_time
 attribute down
Date: Fri, 9 Oct 2015 06:29:05 +0200
Message-ID: <20151009042904.GE2161@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35012 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbbJIE3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:29:07 -0400
Received: by wicge5 with SMTP id ge5so51468118wic.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:29:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 09, 2015 at 04:23:16AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Push bridge-level attributes down to switchdev drivers.  This patchset
>adds the infrastructure and then pushes, as an example, ageing_time attribute
>down from bridge to switchdev (rocker) driver.  Add some range-checking
>for ageing_time.
>
># ip link set dev br0 type bridge ageing_time 1000
>
># ip link set dev br0 type bridge ageing_time 999
>RTNETLINK answers: Numerical result out of range
>
>Up until now, switchdev attrs where port-level attrs, so the netdev used in
>switchdev_attr_set() would be a switch port or bond of switch ports.  With
>bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
>netdev.  The same recusive algo is used to visit the leaves of the stacked
>drivers to set the attr, it's just in this case we start one layer higher in
>the stack.  One note is not all ports in the bridge may support setting a
>bridge-level attribute, so rather than failing the entire set, we'll skip over
>those ports returning -EOPNOTSUPP.
>
>v2->v3: Per Jiri review: push only ageing_time attr down at this time, and
>don't pass raw bridge IFLA_BR_* values; rather use new switchdev attr ID for
>ageing_time.

Looks fine now. Thanks Scott!
