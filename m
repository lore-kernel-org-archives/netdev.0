From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2133] New: bad: scheduling while atomic!
Date: Wed, 18 Feb 2004 11:00:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218110024.3dee0e42.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, michal-bugzilla@logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is possibly a locking bug in the ipv6 code: someone somewhere
forgot to undo a lock and the task ended up in atomic state.
Possibly it is specific to x86_64.

Has anyone run the TAHI suite on x86?



Begin forwarded message:

Date: Wed, 18 Feb 2004 06:31:34 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2133] New: bad: scheduling while atomic!


http://bugme.osdl.org/show_bug.cgi?id=2133

           Summary: bad: scheduling while atomic!
    Kernel Version: 2.6.3
            Status: NEW
          Severity: high
             Owner: other_other@kernel-bugs.osdl.org
         Submitter: michal-bugzilla@logix.cz


Hardware Environment: AMD64
Software Environment: kernel 2.6.3
Problem Description: On my AMD64 machine kernel 2.6.3 I'm getting these messages
while running the TAHI testsuite:

kernel: BUG: dst underflow 0: fffffff802cde24
kernel: last message repeated 6 times
kernel: last message repeated 9 times

kernel: bad: scheduling while atomic!
kernel: Call Trace:{fffff8012fd39}{schedule+73} {fffff8010f7e0}{default_idle+0}

kernel: bad: scheduling while atomic!
kernel: Call Trace:<ffffffff8012fd39>{schedule+73}
<ffffffff80131609>{autoremove_wake_function+9}
<ffffffff801302f8>{__wake_up_common+56} <ffffffff801a7a07>{do_get_write_access+807}
<ffffffff801302b0>{default_wake_function+0}
<ffffffff801a7ea2>{journal_get_undo_access+50}
<ffffffff80196bac>{ext3_try_to_allocate+60} <ffffffff80196ec4>{ext3_new_block+436}
<ffffffff801993f1>{ext3_alloc_block+17} <ffffffff80199805>{ext3_alloc_branch+85}
<ffffffff80199ece>{ext3_get_block_handle+558}
<ffffffff8016a6f4>{alloc_buffer_head+36}
<ffffffff80167fe6>{create_buffers+102} <ffffffff80168e1d>{__block_prepare_write+365}
<ffffffff80199fd0>{ext3_get_block+0} <ffffffff801697fa>{block_prepare_write+26}
<ffffffff8019a5ea>{ext3_prepare_write+106}
<ffffffff8014d62a>{generic_file_aio_write_nolock+1274}
<ffffffff8026e21f>{skb_copy_datagram_iovec+79}
<ffffffff8014da35>{generic_file_write_nolock+149}
<ffffffff8020ec09>{opost_block+425} <ffffffff8011171a>{sysret_careful+13}
<ffffffff80131600>{autoremove_wake_function+0} <ffffffff80210b97>{write_chan+551}
<ffffffff801302b0>{default_wake_function+0}
<ffffffff801302b0>{default_wake_function+0}
<ffffffff8014dc1c>{generic_file_writev+60} <ffffffff80166413>{do_readv_writev+435}
<ffffffff80165e00>{do_sync_write+0} <ffffffff80166659>{sys_writev+73}
<ffffffff801116b0>{system_call+124}

kernel: bad: scheduling while atomic!
kernel: Call Trace:<ffffffff8012fd39>{schedule+73}
<ffffffff801a0f2d>{__ext3_journal_stop+45}
<ffffffff8019a83d>{ext3_ordered_commit_write+189}
<ffffffff8014d8ba>{generic_file_aio_write_nolock+1930}
<ffffffff8026e21f>{skb_copy_datagram_iovec+79}
<ffffffff8014da35>{generic_file_write_nolock+149}
<ffffffff8020ec09>{opost_block+425} <ffffffff80131600>{autoremove_wake_function+0}
<ffffffff80210b97>{write_chan+551} <ffffffff801302b0>{default_wake_function+0}
<ffffffff801302b0>{default_wake_function+0}
<ffffffff8014dc1c>{generic_file_writev+60}
<ffffffff80166413>{do_readv_writev+435} <ffffffff80165e00>{do_sync_write+0}
<ffffffff80166659>{sys_writev+73} <ffffffff801116b0>{system_call+124} 

kernel: Warning: kfree_skb on hard IRG ffffff802c0d4f
kernel: bad: scheduling while atomic!
kernel: Call Trace:{fffff8012fd39}{schedule+73} {fffff8011171a}{sysret_careful+13}

The last message is repeating *many* times per second and so makes the system
unusable.

Steps to reproduce: running tests from 'nd' directory of TAHI testsuite, during
test #21 it breaks, all following tests fail.

Strange conjunction: at the time of the message the screen is sleeping, so I hit
"Alt" to wake it up and surprise - some tests start PASSing again! (at least the
simple ones, like 'ping')

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
