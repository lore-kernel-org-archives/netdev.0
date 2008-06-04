From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][L2TP]: Fix possible WARN_ON from socket code when
 UDP socket is closed
Date: Wed, 04 Jun 2008 15:08:35 -0700 (PDT)
Message-ID: <20080604.150835.73786340.davem@davemloft.net>
References: <200806042056.m54KuiI7003060@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752627AbYFDWIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:08:36 -0400
In-Reply-To: <200806042056.m54KuiI7003060@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 4 Jun 2008 21:56:44 +0100

> If an L2TP daemon closes a tunnel socket while packets are queued in
> the tunnel's reorder queue, a kernel warning is logged because the
> socket is closed while skbs are still referencing it. The fix is to
> purge the queue in the socket's release handler.
> 
> WARNING: at include/net/sock.h:351 udp_lib_unhash+0x41/0x68()
> Pid: 12998, comm: openl2tpd Not tainted 2.6.25 #8
>  [<c0423c58>] warn_on_slowpath+0x41/0x51
>  [<c05d33a7>] udp_lib_unhash+0x41/0x68
>  [<c059424d>] sk_common_release+0x23/0x90
>  [<c05d16be>] udp_lib_close+0x8/0xa
>  [<c05d8684>] inet_release+0x42/0x48
>  [<c0592599>] sock_release+0x14/0x60
>  [<c059299f>] sock_close+0x29/0x30
>  [<c046ef52>] __fput+0xad/0x15b
>  [<c046f1d9>] fput+0x17/0x19
>  [<c046c8c4>] filp_close+0x50/0x5a
>  [<c046da06>] sys_close+0x69/0x9f
>  [<c04048ce>] syscall_call+0x7/0xb
> 
> Signed-off-by: James Chapman <jchapman@katalix.com> 

Applied, thanks.
