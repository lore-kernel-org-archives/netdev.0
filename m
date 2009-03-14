From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [E1000-devel] [stable] Li-nux 2.6.27.19  2.6.28.7
Date: Fri, 13 Mar 2009 18:01:41 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1E80D63A@orsmsx507.amr.corp.intel.com>
References: <20090220225448.GA14122@kroah.com>
	<20090313151051.a9198384.akpm@linux-foundation.org>
 <20090313222044.GA18010@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44978 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbZCNBBo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 21:01:44 -0400
In-Reply-To: <20090313222044.GA18010@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Fri, Mar 13, 2009 at 03:10:51PM -0700, Andrew Morton wrote:
>> 
>> I fired up this kernel up on my FC8 laptop and I see
>> http://userweb.kernel.org/~akpm/p3130212.jpg
>> 
>> On the next two boot attempts, the kernel came up OK.
>> 

root issue:
seems that something with the 2.6.newer doesn't like some of the stuff with the fedora nash stuff.  mkinitrd and friends were updated multiple times to work with these newer kernels in the fedora 10 I was using.  I worked around by changing root=LABEL to use root=/dev/foo in grub.conf
 
>> 
>> ------------[ cut here ]------------
>> WARNING: at drivers/net/e1000e/ich8lan.c:408
>> e1000_acquire_swflag_ich8lan+0x51/0xf2() e1000e mutex contention.
>> Owned by pid 10 
>> Modules linked in:
>> Pid: 9, comm: events/0 Not tainted 2.6.28.7 #1
>> Call Trace:
>>  [<ffffffff8103a810>] warn_slowpath+0xae/0xcd
>>  [<ffffffff8104394b>] ? lock_timer_base+0x26/0x4a
>>  [<ffffffff8104394b>] ? lock_timer_base+0x26/0x4a
>>  [<ffffffff8105d63f>] ? __lock_acquire+0x702/0x760
>>  [<ffffffff8105bfc6>] ? mark_held_locks+0x50/0x6d
>>  [<ffffffff812dd950>] ? mutex_trylock+0x104/0x118
>>  [<ffffffff8105c170>] ? trace_hardirqs_on_caller+0xf8/0x123
>>  [<ffffffff8105c1a8>] ? trace_hardirqs_on+0xd/0xf
>>  [<ffffffff811ed838>] e1000_acquire_swflag_ich8lan+0x51/0xf2
>>  [<ffffffff811f2fe9>] e1000e_read_kmrn_reg+0x1b/0x69
>>  [<ffffffff811f63c5>] ? e1000e_downshift_workaround+0x0/0x12
>>  [<ffffffff811ed1e9>]
>>  e1000e_gig_downshift_workaround_ich8lan+0x2c/0x71
>>  [<ffffffff811f63d5>] e1000e_downshift_workaround+0x10/0x12
>>  [<ffffffff8104a6ed>] run_workqueue+0xf5/0x1fd [<ffffffff8104a697>]
>>  ? run_workqueue+0x9f/0x1fd [<ffffffff8104a8f6>] ?
>>  worker_thread+0x0/0xe8 [<ffffffff8104a9d1>] worker_thread+0xdb/0xe8
>>  [<ffffffff8104de14>] ? autoremove_wake_function+0x0/0x36
>>  [<ffffffff8104a8f6>] ? worker_thread+0x0/0xe8
>>  [<ffffffff8104db1a>] kthread+0x44/0x6b
>>  [<ffffffff8100cf59>] child_rip+0xa/0x11
>>  [<ffffffff8100c474>] ? restore_args+0x0/0x30
>>  [<ffffffff8104dad6>] ? kthread+0x0/0x6b
>>  [<ffffffff8100cf4f>] ? child_rip+0x0/0x11

newer kernels have this fixed.  This really is a warning as this is only telling you that it had to wait (but that the mutex worked!)

we've isolated all these warnings down to known SMP safe paths (and fixed the relevant issues) and have posted a patch to current net-next that removes the warning.  don't have the commit handy but could probably chase it down.

so, WARNING is noisy but okay.

The tx hang you see is bad (as it appears to be a false hang since status is set correctly and you don't get a NETDEV_WATCHDOG)

Jesse

PS please include netdev on network related issues. :-)