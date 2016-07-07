From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: flower: Add skip_{hw|sw} support
Date: Wed, 6 Jul 2016 21:26:01 -0700
Message-ID: <20160706212601.1d0f701d@xeon-e3>
References: <20160704073411.17633-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36053 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750697AbcGGEZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 00:25:47 -0400
Received: by mail-pa0-f44.google.com with SMTP id uj8so2565185pab.3
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 21:25:46 -0700 (PDT)
In-Reply-To: <20160704073411.17633-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  4 Jul 2016 10:34:11 +0300
Amir Vadai <amir@vadai.me> wrote:

> From: Amir Vadai <amirva@mellanox.com>
> 
> On devices that support TC flower offloads, these flags enable a filter to be
> added only to HW or only to SW. skip_sw and skip_hw are mutually exclusive
> flags. By default without any flags, the filter is added to both HW and SW,
> but no error checks are done in case of failure to add to HW.
> With skip-sw, failure to add to HW is treated as an error.
> 
> Here is a sample script that adds 2 filters, one with skip_sw and the other
> with skip_hw flag.
> 
>    # add ingress qdisc
>    tc qdisc add dev enp0s9 ingress
> 
>    # enable hw tc offload.
>    ethtool -K enp0s9 hw-tc-offload on
> 
>    # add a flower filter with skip-sw flag.
>    tc filter add dev enp0s9 protocol ip parent ffff: flower \
> 	   ip_proto 1 indev enp0s9 skip_sw \
> 	   action drop
> 
>    # add a flower filter with skip-hw flag.
>    tc filter add dev enp0s9 protocol ip parent ffff: flower \
> 	   ip_proto 3 indev enp0s9 skip_hw \
> 	   action drop
> 
> Signed-off-by: Amir Vadai <amirva@mellanox.com>

Looks sane. Applied
