From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Mon, 10 Mar 2014 15:23:06 -0400
Message-ID: <531E111A.8040207@hurleysoftware.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Oleg Nesterov <oleg@redhat.com>
To: Sree Harsha Totakura <sreeharsha@totakura.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531DEEA6.4090808@totakura.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ +cc Oleg Nesterov ]

On 03/10/2014 12:56 PM, Sree Harsha Totakura wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Hi,
>
> Using linux-3.13.6, I am observing the following output from the pppd
> kernel thread.  This happens when I try to suspend my computer and it
> *stops* the computer from suspending.
>
> I am using ppp via a bluetooth modem.
>
> Trace:
> [22735.115313] PM: Syncing filesystems ... done.
> [22735.665613] PM: Preparing system for mem sleep
> [22735.665829] Freezing user space processes ...
> [22755.659538] Freezing of tasks failed after 20.004 seconds (1 tasks
> refusing to freeze, wq_
> busy=0):
> [22755.659555] pppd            D ffff8800376c9a58     0 16801      1
> 0x00000006
> [22755.659557]  ffff8800376c9750 0000000000000046 0000000000012e80
> 0000000000012e80
> [22755.659560]  ffff8802a1c1dfd8 ffff8800376c9750 0000000000000009
> ffff8802a1c1dd78
> [22755.659562]  0000000000000046 ffff8800376c9750 0000000000000028
> ffff8800376c9750
> [22755.659564] Call Trace:
> [22755.659569]  [<ffffffff81048507>] ? do_exit+0x937/0xa50
> [22755.659573]  [<ffffffff814bb6e1>] ? oops_end+0x91/0xd0
> [22755.659575]  [<ffffffff814b1f4f>] ? no_context+0x1f3/0x1ff
> [22755.659577]  [<ffffffff814bdb69>] ? __do_page_fault+0x89/0x500
> [22755.659581]  [<ffffffff811017dc>] ? free_pcppages_bulk+0x17c/0x3b0
> [22755.659584]  [<ffffffff81101cce>] ? free_hot_cold_page_list+0x3e/0x90
> [22755.659586]  [<ffffffff814babf8>] ? page_fault+0x28/0x30
> [22755.659591]  [<ffffffffa06fd5a3>] ? ppp_register_channel+0x13/0x20
> [ppp_generic]
> [22755.659594]  [<ffffffffa07062ab>] ? ppp_asynctty_open+0x12b/0x170
> [ppp_async]
> [22755.659596]  [<ffffffff812ec907>] ? tty_ldisc_open.isra.2+0x27/0x60
> [22755.659598]  [<ffffffff812ed1d3>] ? tty_ldisc_hangup+0x1e3/0x220
> [22755.659601]  [<ffffffff812e4614>] ? __tty_hangup+0x2c4/0x440
> [22755.659603]  [<ffffffff812e56a1>] ? disassociate_ctty+0x61/0x270
> [22755.659605]  [<ffffffff810483c2>] ? do_exit+0x7f2/0xa50
> [22755.659607]  [<ffffffff81053ad2>] ? recalc_sigpending+0x12/0x50
> [22755.659609]  [<ffffffff81054308>] ? __set_task_blocked+0x28/0x70
> [22755.659611]  [<ffffffff81048684>] ? do_group_exit+0x34/0xa0
> [22755.659613]  [<ffffffff810486fb>] ? SyS_exit_group+0xb/0x10
> [22755.659615]  [<ffffffff814c1eb9>] ? system_call_fastpath+0x16/0x1b
> [22755.659618]
> [22755.659619] Restarting tasks ... done.
>
> If you need any more info, I am happy to provide.

The NULL ptr dereference is from following the current->nsproxy ptr
in ppp_register_channel().

This was broken by

commit 8aac62706adaaf0fab02c4327761561c8bda9448
Author: Oleg Nesterov <oleg@redhat.com>
Date:   Fri Jun 14 21:09:49 2013 +0200

     move exit_task_namespaces() outside of exit_notify()

which moved the exit_task_namespaces(tsk) before disassociate_ctty().

Regards,
Peter Hurley
