From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bonding-devel] [PATCH 4/4] bonding: add sysfs files to display
 tlb and alb hash	table contents
Date: Mon, 28 Sep 2009 16:22:37 -0700
Message-ID: <20090928162237.6db0c9f5@nehalam>
References: <20090911211317.GT8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49266 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753488AbZI1XWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 19:22:39 -0400
In-Reply-To: <20090911211317.GT8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Sep 2009 17:13:17 -0400
Andy Gospodarek <andy@greyhouse.net> wrote:

> 
> bonding: add sysfs files to display tlb and alb hash table contents
> 
> While debugging some problems with alb (mode 6) bonding I realized that
> being able to output the contents of both hash tables would be helpful.
> This is what the output looks like for the two files:
> 
> device  load
> eth1    491
> eth2    491
> hash device   last device   tx bytes       load        next previous
> 2    eth1     eth1          2254           491         0    0
> 3    eth2     eth2          2744           491         0    0
> 6             eth2          0              488         0    0
> 8             eth2          0              461698      0    0
> 1b            eth2          0              249         0    0
> eb            eth2          0              21          0    0
> ff            eth2          0              22          0    0
> 
> hash ip_src          ip_dst          mac_dst           slave assign ntt
> 2    10.0.3.2        10.0.3.11       00:e0:81:71:ee:a9 eth1  1      0
> 3    10.0.3.2        10.0.3.10       00:e0:81:71:ee:a9 eth2  1      0
> 8    10.0.3.2        10.0.3.1        00:e0:81:71:ee:a9 eth2  1      0
> 
> These were a great help debugging the fixes I have just posted and they
> might be helpful for others, so I decided to include them in my
> patchset.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

No.

Please don't put formatted output in sysfs, it is not meant to be
used like proc, there is supposed to be only one value per file.

Maybe put it on the end of the /proc/net/bonding/bond0 output or
use debugfs
