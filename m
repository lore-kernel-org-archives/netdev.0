From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-rc8-mm1 -- INFO: possible circular locking
 dependency detected (while using iw to debug a wireless issue)
Date: Fri, 4 Apr 2008 10:43:02 -0700
Message-ID: <20080404104302.7445e41f.akpm@linux-foundation.org>
References: <a44ae5cd0804030741jc9c7aebx21a7635e827b190f@mail.gmail.com>
	<1207323936.19189.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ALSA development <alsa-devel@alsa-project.org>,
	YOSHIFUJI@alsa-project.org, Miles Lane <miles.lane@gmail.com>,
	Jouni Malinen <j@w1.fi>, netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Jiri Benc <jbenc@suse.cz>, Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <1207323936.19189.58.camel@johannes.berg>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Fri, 04 Apr 2008 17:45:36 +0200 Johannes Berg <johannes@sipsolutions.net> wrote:

> 
> On Thu, 2008-04-03 at 10:41 -0400, Miles Lane wrote:
> > After collecting the wireshark log, I found this in my messages log:
> 
> Below is a better version of the trace Miles sent me privately, but I
> have no idea what would be causing it. I don't think it's related to
> wireless.
> 
> ___=======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.25-rc8-mm1 #15
> -------------------------------------------------------
> iw/9417 is trying to acquire lock:
> (genl_mutex){--..}, at: [ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0xda
> 
> but task is already holding lock:
> (nlk->cb_mutex){--..}, at: [netlink_dump+0x39/0x22e] netlink_dump+0x39/0x22e
> 
> which lock already depends on the new lock.
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #1 (nlk->cb_mutex){--..}:
> [__lock_acquire+0xa02/0xbaf] __lock_acquire+0xa02/0xbaf
> [lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
> [snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
> [netlink_dump_start+0xbd/0x15a] netlink_dump_start+0xbd/0x15a
> [genl_rcv_msg+0x9d/0x13a] genl_rcv_msg+0x9d/0x13a
> [netlink_rcv_skb+0x30/0x75] netlink_rcv_skb+0x30/0x75
> [genl_rcv+0x1e/0x2e] genl_rcv+0x1e/0x2e
> [cfg80211:netlink_unicast+0x1c1/0x1867] netlink_unicast+0x1c1/0x293
> [netlink_sendmsg+0x21f/0x22c] netlink_sendmsg+0x21f/0x22c
> [sock_sendmsg+0xca/0xe1] sock_sendmsg+0xca/0xe1
> [sys_sendmsg+0x14d/0x1a8] sys_sendmsg+0x14d/0x1a8
> [sys_socketcall+0x163/0x17e] sys_socketcall+0x163/0x17e
> [sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5
>        [<ffffffff>] 0xffffffff
> -> #0 (genl_mutex){--..}:
> [__lock_acquire+0x929/0xbaf] __lock_acquire+0x929/0xbaf
> [lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
> [snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
> [ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0xda
> [netlink_dump+0x51/0x22e] netlink_dump+0x51/0x22e
> [netlink_recvmsg+0x156/0x203] netlink_recvmsg+0x156/0x203
> [sock_recvmsg+0xd1/0xe9] sock_recvmsg+0xd1/0xe9
> [sys_recvmsg+0xf2/0x17f] sys_recvmsg+0xf2/0x17f
> [sys_socketcall+0x16f/0x17e] sys_socketcall+0x16f/0x17e
> [sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5
>        [<ffffffff>] 0xffffffff
> 
> other info that might help us debug this:
> 
> 1 lock held by iw/9417:
>  #0: (nlk->cb_mutex){--..}, at: [netlink_dump+0x39/0x22e] netlink_dump+0x39/0x22e
> 
> stack backtrace:
> Pid: 9417, comm: iw Not tainted 2.6.25-rc8-mm1 #15
> [print_circular_bug_tail+0x5b/0x66] print_circular_bug_tail+0x5b/0x66
> [print_circular_bug_header+0xa5/0xb0] ? print_circular_bug_header+0xa5/0xb0
> [__lock_acquire+0x929/0xbaf] __lock_acquire+0x929/0xbaf
> [lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
> [ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
> [snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
> [ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
> [ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
> [ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0xda
> [netlink_dump+0x51/0x22e] netlink_dump+0x51/0x22e
> [mac80211:kfree_skb+0x40/0x45] ? kfree_skb+0x40/0x45
> [netlink_recvmsg+0x156/0x203] netlink_recvmsg+0x156/0x203
> [sock_sendmsg+0xca/0xe1] ? sock_sendmsg+0xca/0xe1
> [sock_recvmsg+0xd1/0xe9] sock_recvmsg+0xd1/0xe9
> [<c01313d9>] ? autoremove_wake_function+0x0/0x30
> [snd_pcm_oss:copy_from_user+0x3b/0x236] ? copy_from_user+0x3b/0x5e
> [verify_iovec+0x40/0x70] ? verify_iovec+0x40/0x70
> [sys_recvmsg+0xf2/0x17f] sys_recvmsg+0xf2/0x17f
> [snd_hda_intel:_spin_unlock_irqrestore+0x56/0x6c] ? _spin_unlock_irqrestore+0x56/0x6c
> [paravirt_get_lazy_mode+0xe/0x1b] ? paravirt_get_lazy_mode+0xe/0x1b
> [crypto_algapi:kunmap_atomic+0x9e/0x2e8e] ? kunmap_atomic+0x9e/0xbb
> [handle_mm_fault+0x7aa/0x7bb] ? handle_mm_fault+0x7aa/0x7bb
> [sys_socketcall+0x16f/0x17e] sys_socketcall+0x16f/0x17e
> [processor:trace_hardirqs_on+0xf0/0x5d38] ? trace_hardirqs_on+0xf0/0x12c
> [sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5
> 

Yes, that looks like a problem in the core netlink code.  git-net contains
several largeish changes to it..
