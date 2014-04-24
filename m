From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/2] rtnetlink: Only supply IFLA_VF_PORTS information
 when RTEXT_FILTER_VF is set
Date: Thu, 24 Apr 2014 17:51:06 +0200
Message-ID: <20140424155106.GD2864@minipsycho.orion>
References: <1398298956-13084-1-git-send-email-david@gibson.dropbear.id.au>
 <1398298956-13084-3-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:58470 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758158AbaDXPvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:51:09 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so2010597eek.15
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 08:51:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1398298956-13084-3-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 24, 2014 at 02:22:36AM CEST, david@gibson.dropbear.id.au wrote:
>Since 115c9b81928360d769a76c632bae62d15206a94a (rtnetlink: Fix problem with
>buffer allocation), RTM_NEWLINK messages only contain the IFLA_VFINFO_LIST
>attribute if they were solicited by a GETLINK message containing an
>IFLA_EXT_MASK attribute with the RTEXT_FILTER_VF flag.
>
>That was done because some user programs broke when they received more data
>than expected - because IFLA_VFINFO_LIST contains information for each VF
>it can become large if there are many VFs.
>
>However, the IFLA_VF_PORTS attribute, supplied for devices which implement
>ndo_get_vf_port (currently the 'enic' driver only), has the same problem.
>It supplies per-VF information and can therefore become large, but it is
>not currently conditional on the IFLA_EXT_MASK value.
>
>Worse, it interacts badly with the existing EXT_MASK handling.  When
>IFLA_EXT_MASK is not supplied, the buffer for netlink replies is fixed at
>NLMSG_GOODSIZE.  If the information for IFLA_VF_PORTS exceeds this, then
>rtnl_fill_ifinfo() returns -EMSGSIZE on the first message in a packet.
>netlink_dump() will misinterpret this as having finished the listing and
>omit data for this interface and all subsequent ones.  That can cause
>getifaddrs(3) to enter an infinite loop.
>
>This patch addresses the problem by only supplying IFLA_VF_PORTS when
>IFLA_EXT_MASK is supplied with the RTEXT_FILTER_VF flag set.
>
>Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>


This should go to -net I believe.
