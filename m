From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] ipv4: reject RTNH_F_DEAD and RTNH_F_LINKDOWN
 from user space
Date: Mon, 11 Jul 2016 13:41:47 -0700 (PDT)
Message-ID: <20160711.134147.2115995974849910917.davem@davemloft.net>
References: <1468174315-19936-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vegard.nossum@oracle.com,
	gospo@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbcGKUls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:41:48 -0400
In-Reply-To: <1468174315-19936-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 10 Jul 2016 21:11:55 +0300

> Vegard Nossum is reporting for a crash in fib_dump_info
> when nh_dev = NULL and fib_nhs == 1:
 ...
> $ addr2line -e vmlinux -i 0x602b3d18
> include/linux/inetdevice.h:222
> net/ipv4/fib_semantics.c:1264
> 
> Problem happens when RTNH_F_LINKDOWN is provided from user space
> when creating routes that do not use the flag, catched with
> netlink fuzzer.
> 
> Currently, the kernel allows user space to set both flags
> to nh_flags and fib_flags but this is not intentional, the
> assumption was that they are not set. Fix this by rejecting
> both flags with EINVAL.
> 
> Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
> Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queud up for -stable, thanks Julian.
