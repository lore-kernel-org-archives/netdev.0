From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH net-next 0/4] net_cls for sys container
Date: Fri, 3 Jan 2014 11:11:00 +0800
Message-ID: <52C62A44.4070304@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Li Zefan
	<lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi guys,

Now, lxc created with veth can not be under control by
cls_cgroup.

the former discussion:
http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/00214.html

In short, because cls_cgroup relys classid attached to sock
filter skb, but sock will be cleared inside dev_forward_skb()
in veth_xmit().

so I add backup_classid in struct sk_buffer to save classid
before dev_forward_skb(). In cls_cgroup_classify(), if skb->sk
is NULL, we can try to restore classid form skb->bk_classid.


Libo Chen (4):
  net: introduce bk_classid to struct sk_buff
  cls_cgroup: introduce a helper: bk_cls_classid()
  veth: backup classid befor switch net_ns
  cls_cgroup: restore classid from skb->sk_classid

 drivers/net/veth.c       |  5 +++++
 include/linux/skbuff.h   |  3 +++
 include/net/cls_cgroup.h | 11 +++++++++++
 net/sched/cls_cgroup.c   |  8 ++++----
 4 files changed, 23 insertions(+), 4 deletions(-)
