From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] sysctl:  Fix ax25 checks
Date: Mon, 17 Dec 2007 15:44:08 -0700
Message-ID: <m163yxdjrb.fsf_-_@ebiederm.dsl.xmission.com>
References: <476303C8.2060507@ccr.jussieu.fr>
	<20071215101810.GA3143@ami.dom.local>
	<476595EC.5050103@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36715 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762995AbXLQWpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 17:45:39 -0500
In-Reply-To: <476595EC.5050103@ccr.jussieu.fr> (Bernard Pidoux's message of
	"Sun, 16 Dec 2007 22:17:32 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernard Pidoux <pidoux@ccr.jussieu.fr> writes:

> With 2.6.24-rc5 there is no /proc/net/ax25

/proc/sys/net/ax25?

> Here is an extract from dmesg after boot :

Groan.  I thought I had found the last of the bugs with
my sysctl sanity checks.  I guess you actually have to
use ax25 for this bug to show up.

Thank you for catching this. 

> =======================
> sysctl table check failed: /net/ax25/ax0/ax25_default_mode .3.9.1.2 Unknown
> sysctl binary path
> Pid: 2936, comm: kissattach Not tainted 2.6.24-rc5 #1
>  [<c012ca6a>] set_fail+0x3b/0x43
>  [<c012ce7a>] sysctl_check_table+0x408/0x456
>  [<c012ce8e>] sysctl_check_table+0x41c/0x456
>  [<c012ce8e>] sysctl_check_table+0x41c/0x456
>  [<c02ac64a>] _spin_unlock+0x14/0x1c
>  [<c012ce8e>] sysctl_check_table+0x41c/0x456
>  [<c011e681>] sysctl_set_parent+0x19/0x2a
>  [<c011f55c>] register_sysctl_table+0x45/0x85
>  [<d8be9d26>] ax25_register_sysctl+0x112/0x11c [ax25]
>  [<d8be6c76>] ax25_device_event+0x2e/0x90 [ax25]
>  [<c012c560>] notifier_call_chain+0x2a/0x47
>  [<c012c59f>] raw_notifier_call_chain+0x17/0x1a
>  [<c0259290>] dev_open+0x6f/0x75
>  [<c0257ee7>] dev_change_flags+0x9c/0x148
>  [<c0256ab3>] __dev_get_by_name+0x68/0x73
>  [<c0292307>] devinet_ioctl+0x22e/0x53b
>  [<c0259074>] dev_ioctl+0x472/0x5ba
>  [<c024d4ba>] sock_ioctl+0x1aa/0x1cf
>  [<c024d310>] sock_ioctl+0x0/0x1cf
>  [<c016bc19>] do_ioctl+0x19/0x4c
>  [<c016be40>] vfs_ioctl+0x1f4/0x20b
>  [<c0103d01>] sysenter_past_esp+0x9a/0xa9
>  [<c016be9c>] sys_ioctl+0x45/0x5d
>  [<c0103cc6>] sysenter_past_esp+0x5f/0xa9
>  =======================
> sysctl table check failed: /net/ax25/ax0/backoff_type .3.9.1.3 Unknown sysctl
> binary path
> (...) truncated
>  =======================
> sysctl table check failed: /net/ax25/ax0/connect_mode .3.9.1.4 Unknown sysctl
> binary path
> (...)
>  =======================
> sysctl table check failed: /net/ax25/ax0/standard_window_size .3.9.1.5 Unknown
> sysctl binary path
>  =======================
> (...)
>
> and so on ...
>

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 kernel/sysctl_check.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index bed939f..a68425a 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -428,7 +428,7 @@ static struct trans_ctl_table trans_net_netrom_table[] = {
 	{}
 };
 
-static struct trans_ctl_table trans_net_ax25_table[] = {
+static struct trans_ctl_table trans_net_ax25_param_table[] = {
 	{ NET_AX25_IP_DEFAULT_MODE,	"ip_default_mode" },
 	{ NET_AX25_DEFAULT_MODE,	"ax25_default_mode" },
 	{ NET_AX25_BACKOFF_TYPE,	"backoff_type" },
@@ -446,6 +446,11 @@ static struct trans_ctl_table trans_net_ax25_table[] = {
 	{}
 };
 
+static struct trans_ctl_table trans_net_ax25_table[] = {
+	{ 0, NULL, trans_net_ax25_param_table },
+	{}
+};
+
 static struct trans_ctl_table trans_net_bridge_table[] = {
 	{ NET_BRIDGE_NF_CALL_ARPTABLES,		"bridge-nf-call-arptables" },
 	{ NET_BRIDGE_NF_CALL_IPTABLES,		"bridge-nf-call-iptables" },
-- 
1.5.3.rc6.17.g1911

