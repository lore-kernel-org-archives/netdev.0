From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2] tc: flower: Add skip_{hw|sw} support
Date: Mon, 4 Jul 2016 09:41:34 +0200
Message-ID: <20160704074133.GA2325@nanopsycho.orion>
References: <20160704073411.17633-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37724 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbcGDHlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 03:41:37 -0400
Received: by mail-wm0-f43.google.com with SMTP id a66so103247909wme.0
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 00:41:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160704073411.17633-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 04, 2016 at 09:34:11AM CEST, amir@vadai.me wrote:
>From: Amir Vadai <amirva@mellanox.com>
>
>On devices that support TC flower offloads, these flags enable a filter to be
>added only to HW or only to SW. skip_sw and skip_hw are mutually exclusive
>flags. By default without any flags, the filter is added to both HW and SW,
>but no error checks are done in case of failure to add to HW.
>With skip-sw, failure to add to HW is treated as an error.
>
>Here is a sample script that adds 2 filters, one with skip_sw and the other
>with skip_hw flag.
>
>   # add ingress qdisc
>   tc qdisc add dev enp0s9 ingress
>
>   # enable hw tc offload.
>   ethtool -K enp0s9 hw-tc-offload on
>
>   # add a flower filter with skip-sw flag.
>   tc filter add dev enp0s9 protocol ip parent ffff: flower \
>	   ip_proto 1 indev enp0s9 skip_sw \
>	   action drop
>
>   # add a flower filter with skip-hw flag.
>   tc filter add dev enp0s9 protocol ip parent ffff: flower \
>	   ip_proto 3 indev enp0s9 skip_hw \
>	   action drop
>
>Signed-off-by: Amir Vadai <amirva@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
