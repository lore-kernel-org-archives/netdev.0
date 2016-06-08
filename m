From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Introduce support in
 SKIP SW flag
Date: Wed, 8 Jun 2016 09:04:43 +0300
Message-ID: <20160608060443.GA19287@office.localdomain>
References: <20160605141118.10986-1-amir@vadai.me>
 <5756EA44.7050301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36544 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbcFHGEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 02:04:47 -0400
Received: by mail-wm0-f65.google.com with SMTP id m124so154668wme.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 23:04:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5756EA44.7050301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 08:37:40AM -0700, John Fastabend wrote:
> On 16-06-05 07:11 AM, Amir Vadai wrote:
> > From: Amir Vadai <amirva@mellanox.com>
> > 
> > In order to make a filter processed only by hardware, skip_sw flag
> > should be supplied. This is an addition to the already existing skip_hw
> > flag (filter will be processed by software only). If no flag is
> > specified, filter will be processed by both software and hardware.
> > 
> > If only hardware offloaded filters exist, fl_classify() will return
> > without doing anything.
> > 
> > A following userspace patch will be sent once kernel patch is accepted.
> > 
> > Example:
> > 
> > tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
> > 	flower \
> > 		ip_proto 6 \
> > 		indev enp0s9 \
> > 		skip_sw \
> > 	action skbedit mark 0x1234
> > 
> > Signed-off-by: Amir Vadai <amirva@mellanox.com>
> > ---
> 
> 
> 
> Looks good to me. Although we need to do the same error propagation in
> flower that Jakub just added to cls_u32.
Thanks John,
I will send a patch to return error when add to hw is failing and skip_sw
is set.

> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
