From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Introduce support in SKIP
 SW flag
Date: Tue, 7 Jun 2016 08:37:40 -0700
Message-ID: <5756EA44.7050301@gmail.com>
References: <20160605141118.10986-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34774 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843AbcFGPhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 11:37:54 -0400
Received: by mail-pf0-f194.google.com with SMTP id l188so4026919pfl.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 08:37:54 -0700 (PDT)
In-Reply-To: <20160605141118.10986-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-05 07:11 AM, Amir Vadai wrote:
> From: Amir Vadai <amirva@mellanox.com>
> 
> In order to make a filter processed only by hardware, skip_sw flag
> should be supplied. This is an addition to the already existing skip_hw
> flag (filter will be processed by software only). If no flag is
> specified, filter will be processed by both software and hardware.
> 
> If only hardware offloaded filters exist, fl_classify() will return
> without doing anything.
> 
> A following userspace patch will be sent once kernel patch is accepted.
> 
> Example:
> 
> tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
> 	flower \
> 		ip_proto 6 \
> 		indev enp0s9 \
> 		skip_sw \
> 	action skbedit mark 0x1234
> 
> Signed-off-by: Amir Vadai <amirva@mellanox.com>
> ---



Looks good to me. Although we need to do the same error propagation in
flower that Jakub just added to cls_u32.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
