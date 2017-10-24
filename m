From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 197367] New: NMI watchdog: BUG: soft lockup - CPU#1 stuck
 for 22s! [nf_conntrack]
Date: Tue, 24 Oct 2017 15:05:41 +0200
Message-ID: <20171024150541.71368011@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 23 Oct 2017 16:17:38 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 197367] New: NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [nf_conntrack]


https://bugzilla.kernel.org/show_bug.cgi?id=197367

            Bug ID: 197367
           Summary: NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s!
                    [nf_conntrack]
           Product: Networking
           Version: 2.5
    Kernel Version: 4.8.13-1.el6.elrepo.x86_64
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: svimik@gmail.com
        Regression: No

Created attachment 260349
  --> https://bugzilla.kernel.org/attachment.cgi?id=260349&action=edit  
oops message

Hi,

Got the following kernel panic (see full message in attachment):

NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [openvpn:1436]
----cut----
CPU: 1 PID: 1436 Comm: openvpn Not tainted 4.8.13-1.el6.elrepo.x86_64 #1
Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
task: ffff88003c564300 task.stack: ffff88003bfb0000
RIP: 0010:[<ffffffffa030859f>]  [<ffffffffa030859f>]
__nf_conntrack_find_get+0x3f/0x330 [nf_conntrack]
----cut----
Call Trace:
<IRQ>
[<ffffffffa03084b0>] ? death_by_timeout+0x20/0x20 [nf_conntrack]
[<ffffffffa0306ceb>] ? nf_ct_get_tuple+0x8b/0xb0 [nf_conntrack]
[<ffffffffa0308ac0>] nf_conntrack_in+0x1e0/0x530 [nf_conntrack]
[<ffffffffa032414c>] ipv4_conntrack_in+0x1c/0x20 [nf_conntrack_ipv4]
[<ffffffff8169f782>] nf_iterate+0x72/0x90
[<ffffffff816aa68f>] ? ip_rcv_finish+0x16f/0x3d0
[<ffffffff8169f8dd>] nf_hook_slow+0x3d/0xc0
[<ffffffff816aad46>] ip_rcv+0x2d6/0x3d0
[<ffffffffa004a402>] ? virtqueue_add_inbuf+0x2/0x30 [virtio_ring]
[<ffffffff816aa520>] ? inet_add_protocol+0x50/0x50
[<ffffffffa00490fa>] ? virtqueue_notify+0x1a/0x40 [virtio_ring]
[<ffffffff816669e0>] __netif_receive_skb_core+0x5b0/0x9f0
[<ffffffffa01372d0>] ? start_xmit+0x110/0x210 [virtio_net]
[<ffffffff810b796a>] ? update_cfs_rq_load_avg+0x29a/0x430
[<ffffffff8179b640>] ? _raw_read_unlock_bh+0x20/0x30
[<ffffffffa02d9900>] ? ebt_do_table+0x620/0x690 [ebtables]
[<ffffffff81666e49>] __netif_receive_skb+0x29/0x70
[<ffffffff81667067>] netif_receive_skb_internal+0x37/0x90
[<ffffffff81667ed8>] netif_receive_skb+0x28/0x80
----cut----

A full message of this oops can be found in attachment. Message was received
using netconsole.

-- 
You are receiving this mail because:
You are the assignee for the bug.
