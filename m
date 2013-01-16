From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Wed, 16 Jan 2013 15:27:39 -0500 (EST)
Message-ID: <20130116.152739.1410405748417543201.davem@davemloft.net>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab3APU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 15:27:43 -0500
In-Reply-To: <1358242446-4273-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 15 Jan 2013 17:34:06 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> v4: hold rtnl lock for the whole netpoll_setup()
> v3: remove the comment
> v2: use RCU read lock
> 
> This patch fixes the following warning:
> 
> [   72.013864] RTNL: assertion failed at net/core/dev.c (4955)
> [   72.017758] Pid: 668, comm: netpoll-prep-v6 Not tainted 3.8.0-rc1+ #474
> [   72.019582] Call Trace:
> [   72.020295]  [<ffffffff8176653d>] netdev_master_upper_dev_get+0x35/0x58
> [   72.022545]  [<ffffffff81784edd>] netpoll_setup+0x61/0x340
> [   72.024846]  [<ffffffff815d837e>] store_enabled+0x82/0xc3
> [   72.027466]  [<ffffffff815d7e51>] netconsole_target_attr_store+0x35/0x37
> [   72.029348]  [<ffffffff811c3479>] configfs_write_file+0xe2/0x10c
> [   72.030959]  [<ffffffff8115d239>] vfs_write+0xaf/0xf6
> [   72.032359]  [<ffffffff81978a05>] ? sysret_check+0x22/0x5d
> [   72.033824]  [<ffffffff8115d453>] sys_write+0x5c/0x84
> [   72.035328]  [<ffffffff819789d9>] system_call_fastpath+0x16/0x1b
> 
> In case of other races, hold rtnl lock for the entire netpoll_setup() function.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
