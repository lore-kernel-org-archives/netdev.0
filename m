From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Sat, 07 Jan 2012 10:14:50 -0800 (PST)
Message-ID: <20120107.101450.2214394343146869929.davem@davemloft.net>
References: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com>
	<7449.1325885605@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxim.uvarov@oracle.com, netdev@vger.kernel.org,
	andy@greyhouse.net, amwang@redhat.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2AGSPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 13:15:07 -0500
In-Reply-To: <7449.1325885605@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 06 Jan 2012 13:33:25 -0800

> Maxim Uvarov <maxim.uvarov@oracle.com> wrote:
> 
>>No need to lock soft irqs under bond_alb_xmit()
>>which already has softirq disabled.
> 
> 	In commit:
> 
> commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Wed Oct 17 17:37:50 2007 -0700
> 
>     bonding: Convert more locks to _bh, acquire rtnl, for new locking
>     
>         Convert more lock acquisitions to _bh flavor to avoid deadlock
>     with workqueue activity and add acquisition of RTNL in appropriate places.
>     Affects ALB mode, as well as core bonding functions and sysfs.
>     
>     Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>     Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
> 	the _lock_tx_hashtbl was upgraded from regular to _bh to prevent
> deadlocks.  I don't recall right offhand what deadlock this prevented,
> but are we sure there are no possible issues with converting this lock
> back to a non-_bh acquisition?

Maxim's patch is not changing the BH'ness of the list.


He's just avoiding a BH disable which is unnecessary because BH is
already disabled in the effected code path(s).
