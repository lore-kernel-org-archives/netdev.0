From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: ipsec hang
Date: Wed, 24 Nov 2004 19:10:57 +0100
Message-ID: <41A4CEB1.7000001@trash.net>
References: <20041123173111.1b74fabb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030605060200040204090409"
Cc: netdev@oss.sgi.com, =?ISO-8859-1?Q?Marcin_Gibu=B3a?= <mg@iceni.pl>,
        jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041123173111.1b74fabb.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030605060200040204090409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id iAOIDnvS026896

Andrew Morton wrote:

>Looks like one of the chains off xfrm_policy_list[] might have gone
>circular?
>
This patch fixes it. When a policy with a priority lower than an
existing policy is inserted, it loops forever on the existing policy.

Regards
Patrick

>Begin forwarded message:
>
>Date: Wed, 24 Nov 2004 01:34:49 +0100
>From: Marcin Gibu=B3a <mg@iceni.pl>
>To: linux-kernel@vger.kernel.org
>Subject: ipsec hang
>
>
>Hi,
>today I tried to configure ipsec on my linux workstation (with openswan)=
 and=20
>it hanged just after the init had run /etc/rc.d/init.d/ipsec start.=20
>It was on linux-2.6.10-rc1-bk20, so I upgraded to 2.6.10-rc2-mm3 but it =
didn't=20
>make any difference.=20
>
>The alt-sysrq-p shows the following call trace:
>xfrm_policy_insert
>xfrm_netlink_rcv
>netlink_data_ready
>netlink_sendmsg
>sock_aio_write
>do_sync_write
>sock_map_fd
>sys_select
>vfs_write
>system_call
>


--------------030605060200040204090409
Content-Type: text/plain;
 name="x"
Content-Disposition: inline;
 filename="x"
Content-Transfer-Encoding: 7bit

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/23 18:21:09-08:00 kaber@trash.net 
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   The patch 'Fix policy update bug when increasing
#   priority of last policy' broke this, when a policy
#   with lower priority than an existing policy is inserted
#   xfrm_policy_insert loops forever.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/xfrm/xfrm_policy.c
#   2004/11/23 18:20:49-08:00 kaber@trash.net +1 -0
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   The patch 'Fix policy update bug when increasing
#   priority of last policy' broke this, when a policy
#   with lower priority than an existing policy is inserted
#   xfrm_policy_insert loops forever.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-11-24 19:01:38 +01:00
+++ b/net/xfrm/xfrm_policy.c	2004-11-24 19:01:38 +01:00
@@ -353,6 +353,7 @@
 			newpos = p;
 		if (delpol)
 			break;
+		p = &pol->next;
 	}
 	if (newpos)
 		p = newpos;

--------------030605060200040204090409--
