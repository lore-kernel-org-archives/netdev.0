From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate
 modules
Date: Tue, 28 Oct 2014 17:27:43 -0400 (EDT)
Message-ID: <20141028.172743.459865270069950735.davem@davemloft.net>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
	<20141028.144344.398016097830457432.davem@davemloft.net>
	<CAADnVQ+Z6-7sdWAEvHkKR==Nds6hqBfbfPmtUDiZXOTE9DRnGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dev@openvswitch.org, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaJ1V1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:27:46 -0400
In-Reply-To: <CAADnVQ+Z6-7sdWAEvHkKR==Nds6hqBfbfPmtUDiZXOTE9DRnGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 28 Oct 2014 13:57:13 -0700

> On Tue, Oct 28, 2014 at 11:43 AM, David Miller <davem@davemloft.net> wrote:
>> From: Thomas Graf <tgraf@suug.ch>
>> Date: Wed, 22 Oct 2014 17:29:06 +0200
>>
>>> The internal and netdev vport remain part of openvswitch.ko. Encap
>>> vports including vxlan, gre, and geneve can be built as separate
>>> modules and are loaded on demand. Modules can be unloaded after use.
>>> Datapath ports keep a reference to the vport module during their
>>> lifetime.
>>>
>>> Allows to remove the error prone maintenance of the global list
>>> vport_ops_list.
>>>
>>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>>
>> Applied, thanks a lot Thomas.
> 
> Thomas,
> 
> it fails the build when lockdep is on:
> ERROR: "lockdep_ovsl_is_held" [net/openvswitch/vport-gre.ko] undefined!

I've fixed it thusly:

====================
[PATCH] openvswitch: Export lockdep_ovsl_is_held to modules.

ERROR: "lockdep_ovsl_is_held" [net/openvswitch/vport-gre.ko] undefined!

Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/openvswitch/datapath.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index aecddb9..f18302f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -131,6 +131,7 @@ int lockdep_ovsl_is_held(void)
 	else
 		return 1;
 }
+EXPORT_SYMBOL(lockdep_ovsl_is_held);
 #endif
 
 static struct vport *new_vport(const struct vport_parms *);
-- 
1.7.11.7
