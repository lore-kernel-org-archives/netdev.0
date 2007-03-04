From: Matt Mackall <mpm@selenic.com>
Subject: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Sun, 4 Mar 2007 16:08:57 -0600
Message-ID: <20070304220857.GH23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751834AbXCDWVj@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent kernels are having troubles with wireless for me. Two seemingly
related problems:

a) NetworkManager seems oblivious to the existence of my IPW2200
b) Manual iwconfig waits for 60s and then reports:

Error for wireless request "Set Encode" (8B2A) :
    SET failed on device eth1 ; Operation not supported.

During this time, my keyboard in X is unresponsive, but everything
else seems to be functioning properly. Queued keypresses eventually
show up. Alt-sysrq-w gives:

ieee80211_crypt: registered algorithm 'WEP'
SysRq : Show Blocked State

                         free                        sibling
  task             PC    stack   pid father child younger older
events/0      D C0102D3C     0     4      1             5     3
(L-TLB)
       c1d0bf1c 00000046 c1d0ac20 c0102d3c 00000000 c1d0aa70 00000022
       0000000a
       c1d0aa70 ca8ed618 00000034 00000cd3 c1d0ab7c 00000287 00000002
       f581f040
       00000002 c1d0bf34 00000246 f7b5cb04 c1d0aa70 c038224e c0102c3a
       00000000
Call Trace:
 [<c0102d3c>] __switch_to+0x11b/0x143
 [<c038224e>] __mutex_lock_slowpath+0xfb/0x1e2
 [<c0102c3a>] __switch_to+0x19/0x143
 [<f994a291>] ipw_bg_link_down+0x19/0xbd [ipw2200]
 [<f994a278>] ipw_bg_link_down+0x0/0xbd [ipw2200]
 [<c0122604>] run_workqueue+0x97/0x156
 [<c0122bc7>] worker_thread+0x105/0x12e
 [<c0112399>] default_wake_function+0x0/0xc
 [<c0122ac2>] worker_thread+0x0/0x12e
 [<c01251f7>] kthread+0xa0/0xc9
 [<c0125157>] kthread+0x0/0xc9
 [<c0103f87>] kernel_thread_helper+0x7/0x10
 =======================
ipw2200/0     D 00000020     0  1985      6          2260  1983
(L-TLB)
       f7981f24 00000046 00000001 00000020 c1cdf8c0 00000000 00000000
       0000000a
       f7d09030 e1fdc8c3 00000034 0000093a f7d0913c 00000086 00000020
       f7c4a740
       00000086 f7981f3c 00000246 f7b5cb04 f7d09030 c038224e f7d09030
       c0496550
Call Trace:
 [<c038224e>] __mutex_lock_slowpath+0xfb/0x1e2
 [<c0381233>] __sched_text_start+0x4b3/0x56b
 [<f99445c6>] ipw_bg_gather_stats+0x0/0x27 [ipw2200]
 [<f99445dd>] ipw_bg_gather_stats+0x17/0x27 [ipw2200]
 [<c0122604>] run_workqueue+0x97/0x156
 [<c0122bc7>] worker_thread+0x105/0x12e
 [<c0112399>] default_wake_function+0x0/0xc
 [<c0122ac2>] worker_thread+0x0/0x12e
 [<c01251f7>] kthread+0xa0/0xc9
 [<c0125157>] kthread+0x0/0xc9
 [<c0103f87>] kernel_thread_helper+0x7/0x10
 =======================
ieee80211_crypt_wep: could not allocate crypto API arc4
eth1: could not initialize WEP: load module ieee80211_crypt_wep
ADDRCONF(NETDEV_UP): eth1: link is not ready

A second attempt to enable WEP via iwconfig succeeds and network
connectivity is normal. However, NetworkManager still ignores the
device at this point.

Bisect with Mercurial points to this patch:

$ hg bisect bad
The first bad revision is:
changeset:   46985:f701b96bb2f7
user:        Greg Kroah-Hartman <gregkh@suse.de>
date:        Wed Feb 07 10:37:11 2007 -0800
summary:     Network: convert network devices to use struct device
instead of class_device

which corresponds to 43cb76d91ee85f579a69d42bc8efc08bac560278 in git.

-- 
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 
