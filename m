From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: PROBLEM: NULL pointer dereference in rpcauth_refreshcred
Date: Sun, 24 Oct 2010 17:29:21 -0400
Message-ID: <1287955761.2915.1.camel@heimdal.trondhjem.org>
References: <3DE04C32-0B15-4BBF-A541-27152D3EC69B@mars.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Leslie <rob-O+g/SLjAo04@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3DE04C32-0B15-4BBF-A541-27152D3EC69B-O+g/SLjAo04@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-10-23 at 14:50 -0700, Rob Leslie wrote:
> [1.] One line summary of the problem:
> 
> NULL pointer dereference in rpcauth_refreshcred

Hi Rob,

I suspect the following one-line patch should fix the problem.

Cheers
  Trond
------------------------------------------------------------------------------------------------------
>From 118df3d17f11733b294ea2cd988d56ee376ef9fd Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Date: Sun, 24 Oct 2010 17:17:31 -0400
Subject: [PATCH] SUNRPC: After calling xprt_release(), we must restart from call_reserve

Rob Leslie reports seeing the following Oops after his Kerberos session
expired.

BUG: unable to handle kernel NULL pointer dereference at 00000058
IP: [<e186ed94>] rpcauth_refreshcred+0x11/0x12c [sunrpc]
*pde = 00000000
Oops: 0000 [#1]
last sysfs file: /sys/devices/platform/pc87360.26144/temp3_input
Modules linked in: autofs4 authenc esp4 xfrm4_mode_transport ipt_LOG ipt_REJECT xt_limit xt_state ipt_REDIRECT xt_owner xt_HL xt_hl xt_tcpudp xt_mark cls_u32 cls_tcindex sch_sfq sch_htb sch_dsmark geodewdt deflate ctr twofish_generic twofish_i586 twofish_common camellia serpent blowfish cast5 cbc xcbc rmd160 sha512_generic sha1_generic hmac crypto_null af_key rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ip_gre sit tunnel4 dummy ext3 jbd nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_conntrack_ftp iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables pc8736x_gpio nsc_gpio pc87360 hwmon_vid loop aes_i586 aes_generic sha256_generic dm_crypt cs5535_gpio serio_raw cs5535_mfgpt hifn_795x des_generic geode_rng rn
 g_core led_class ext4 mbcache jbd2 crc16 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif ide_pci_generic cs5536 amd74xx ide_core pata_cs5536 ata_generic libata usb_storage via_rhine mii scsi_mod btrfs zlib_deflate crc32c libcrc32c [last unloaded: scsi_wait_scan]

Pid: 12875, comm: sudo Not tainted 2.6.36-net5501 #1 /
EIP: 0060:[<e186ed94>] EFLAGS: 00010292 CPU: 0
EIP is at rpcauth_refreshcred+0x11/0x12c [sunrpc]
EAX: 00000000 EBX: defb13a0 ECX: 00000006 EDX: e18683b8
ESI: defb13a0 EDI: 00000000 EBP: 00000000 ESP: de571d58
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process sudo (pid: 12875, ti=de570000 task=decd1430 task.ti=de570000)
Stack:
 e186e008 00000000 defb13a0 0000000d deda6000 e1868f22 e196f12b defb13a0
<0> defb13d8 00000000 00000000 e186e0aa 00000000 defb13a0 de571dac 00000000
<0> e186956c de571e34 debea5c0 de571dc8 e186967a 00000000 debea5c0 de571e34
Call Trace:
 [<e186e008>] ? rpc_wake_up_next+0x114/0x11b [sunrpc]
 [<e1868f22>] ? call_decode+0x24a/0x5af [sunrpc]
 [<e196f12b>] ? nfs4_xdr_dec_access+0x0/0xa2 [nfs]
 [<e186e0aa>] ? __rpc_execute+0x62/0x17b [sunrpc]
 [<e186956c>] ? rpc_run_task+0x91/0x97 [sunrpc]
 [<e186967a>] ? rpc_call_sync+0x40/0x5b [sunrpc]
 [<e1969ca2>] ? nfs4_proc_access+0x10a/0x176 [nfs]
 [<e19572fa>] ? nfs_do_access+0x2b1/0x2c0 [nfs]
 [<e186ed61>] ? rpcauth_lookupcred+0x62/0x84 [sunrpc]
 [<e19573b6>] ? nfs_permission+0xad/0x13b [nfs]
 [<c0177824>] ? exec_permission+0x15/0x4b
 [<c0177fbd>] ? link_path_walk+0x4f/0x456
 [<c017867d>] ? path_walk+0x4c/0xa8
 [<c0179678>] ? do_path_lookup+0x1f/0x68
 [<c017a3fb>] ? user_path_at+0x37/0x5f
 [<c016359c>] ? handle_mm_fault+0x229/0x55b
 [<c0170a2d>] ? sys_faccessat+0x93/0x146
 [<c0170aef>] ? sys_access+0xf/0x13
 [<c02cf615>] ? syscall_call+0x7/0xb
Code: 0f 94 c2 84 d2 74 09 8b 44 24 0c e8 6a e9 8b de 83 c4 14 89 d8 5b 5e 5f 5d c3 55 57 56 53 83 ec 1c fc 89 c6 8b 40 10 89 44 24 04 <8b> 58 58 85 db 0f 85 d4 00 00 00 0f b7 46 70 8b 56 20 89 c5 83
EIP: [<e186ed94>] rpcauth_refreshcred+0x11/0x12c [sunrpc] SS:ESP 0068:de571d58
CR2: 0000000000000058

This appears to be caused by the function rpc_verify_header() first
calling xprt_release(), then doing a call_refresh. If we release the
transport slot, we should _always_ jump back to call_reserve before
calling anything else.

Signed-off-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
---
 net/sunrpc/clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2388d83..3d28ae8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1677,7 +1677,7 @@ rpc_verify_header(struct rpc_task *task)
 			rpcauth_invalcred(task);
 			/* Ensure we obtain a new XID! */
 			xprt_release(task);
-			task->tk_action = call_refresh;
+			task->tk_action = call_reserve;
 			goto out_retry;
 		case RPC_AUTH_BADCRED:
 		case RPC_AUTH_BADVERF:
-- 
1.7.2.3


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
