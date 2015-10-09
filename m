From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 0/4] switchdev: push bridge ageing_time
 attribute down
Date: Thu, 8 Oct 2015 19:40:50 -0700
Message-ID: <CAGVrzcYdnvR334vSnPbM+Jgm93Coekv3xQJ+O37LHtH0touK6w@mail.gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34966 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354AbbJICla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:41:30 -0400
Received: by igbkq10 with SMTP id kq10so26572111igb.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:41:30 -0700 (PDT)
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-08 19:23 GMT-07:00  <sfeldma@gmail.com>:
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

Other than the small question on patch #3, this looks good to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>
> v2->v3: Per Jiri review: push only ageing_time attr down at this time, and
> don't pass raw bridge IFLA_BR_* values; rather use new switchdev attr ID for
> ageing_time.
>
> v1->v2: rebase w/ net-next
>
>
> Scott Feldman (4):
>   switchdev: add bridge ageing_time attribute
>   switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
>   bridge: push bridge setting ageing_time down to switchdev
>   rocker: handle setting bridge ageing_time
>
>  drivers/net/ethernet/rocker/rocker.c |   16 ++++++++++++++++
>  include/net/switchdev.h              |    3 +++
>  net/bridge/br_ioctl.c                |    3 +--
>  net/bridge/br_netlink.c              |    6 +++---
>  net/bridge/br_private.h              |    1 +
>  net/bridge/br_stp.c                  |   23 +++++++++++++++++++++++
>  net/bridge/br_sysfs_br.c             |    3 +--
>  net/switchdev/switchdev.c            |    9 ++++++++-
>  8 files changed, 56 insertions(+), 8 deletions(-)
>
> --
> 1.7.10.4
>



-- 
Florian
