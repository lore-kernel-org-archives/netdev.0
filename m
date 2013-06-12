From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: sctp_seq_dump_local_addrs: fix NULL pointer
 dereference
Date: Wed, 12 Jun 2013 15:17:38 -0400
Message-ID: <51B8C952.7070401@gmail.com>
References: <1370969266-16974-1-git-send-email-dborkman@redhat.com> <20130612125600.GF13059@hmsreliant.think-freely.org> <51B871CE.3090602@redhat.com> <51B87575.2070102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:65499 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab3FLTRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 15:17:42 -0400
In-Reply-To: <51B87575.2070102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 09:19 AM, Daniel Borkmann wrote:
> On 06/12/2013 03:04 PM, Daniel Borkmann wrote:
>> On 06/12/2013 02:56 PM, Neil Horman wrote:
>>> On Tue, Jun 11, 2013 at 06:47:46PM +0200, Daniel Borkmann wrote:
>>>> The following NULL pointer dereference has occured on a 2.6.32-358
>>>> kernel,
>>>> but upstream is affected as well since there are not many differences:
>>>>
>>>> sctp protocol violation state 4 chunkid 8
>>>> BUG: unable to handle kernel NULL pointer dereference at
>>>> 0000000000000078
>>>> IP: [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
>>>> PGD c2758c067 PUD 87ecf1067 PMD 0
>>>> Oops: 0000 [#1] SMP
>>>> last sysfs file:
>>>> /sys/devices/pci0000:00/0000:00:0a.0/0000:02:00.1/local_cpus
>>>> CPU 7
>>>> Modules linked in: [...]
>>>> Pid: 15475, comm: netstat Not tainted 2.6.32-358.el6.x86_64 #1
>>>> KONTRON AT8050/FYA/AT8050/FYA
>>>> RIP: 0010:[<ffffffffa0354cac>]  [<ffffffffa0354cac>]
>>>> sctp_v4_cmp_addr+0xc/0x30 [sctp]
>>>> RSP: 0018:ffff880c280f3d08  EFLAGS: 00010206
>>>> RAX: 0000000000000002 RBX: ffff880827a25c00 RCX: 0000000000000001
>>>> RDX: 000000000000027f RSI: 0000000000000078 RDI: ffff880827a25c20
>>>> RBP: ffff880c280f3d08 R08: 00000000fffffffd R09: 0000000000000001
>>>> R10: 0000000000000003 R11: 0000000000000000 R12: ffff880c27d9d870
>>>> R13: ffffffffa03751c0 R14: ffff880827a25c20 R15: 0000000000000078
>>>> FS:  00007fb7b7d0f7a0(0000) GS:ffff8800282e0000(0000)
>>>> knlGS:0000000000000000
>>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>>   -- MORE --  forward: <SPACE>, <ENTER> or j  backward: b or k  quit: q
>>>> CR2: 0000000000000078 CR3: 000000087c36d000 CR4: 00000000000007e0
>>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>>> Process netstat (pid: 15475, threadinfo ffff880c280f2000, task
>>>> ffff88091e361540)
>>>> Stack:
>>>>   ffff880c280f3d58 ffffffffa036dbac ffff880c280f3d28 ffff88098fefebc0
>>>> <d> ffff880c280f3d38 ffff880c27d9d800 ffff88098fefebc0 0000000000000f83
>>>> <d> ffff8808d12a7b80 ffff880c27d9d948 ffff880c280f3e18 ffffffffa036de3d
>>>> Call Trace:
>>>>   [<ffffffffa036dbac>] sctp_seq_dump_local_addrs+0x6c/0xc0 [sctp]
>>>>   [<ffffffffa036de3d>] sctp_assocs_seq_show+0x12d/0x250 [sctp]
>>>>   [<ffffffff811a4ee0>] ? seq_read+0x0/0x400
>>>>   [<ffffffff811a5169>] seq_read+0x289/0x400
>>>>   [<ffffffff811e966e>] proc_reg_read+0x7e/0xc0
>>>>   [<ffffffff811816c5>] vfs_read+0xb5/0x1a0
>>>>   [<ffffffff81181801>] sys_read+0x51/0x90
>>>>   [<ffffffff810dc565>] ? __audit_syscall_exit+0x265/0x290
>>>>   [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
>>>> Code: 02 00 08 8b 47 04 89 46 04 b8 08 00 00 00 c9 c3 66 66 66 66 66 66
>>>>        2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 44 00 00 0f b7
>>>> 07 <66>
>>>>        3b 06 74 07 31 c0 c9 c3 0f 1f 00 0f b7 47 02 66 3b 46 02 75
>>>> RIP  [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
>>>>   RSP <ffff880c280f3d08>
>>>> CR2: 0000000000000078
>>>>
>>>> ./decodecode < oops.file:
>>>>    ...
>>>>    1f:    55                       push   %rbp
>>>>    20:    48 89 e5                 mov    %rsp,%rbp
>>>>    23:    0f 1f 44 00 00           nopl   0x0(%rax,%rax,1)
>>>>    28:    0f b7 07                 movzwl (%rdi),%eax
>>>>    2b:*    66 3b 06                 cmp    (%rsi),%ax  <-- trapping
>>>> instruction
>>>>    2e:    74 07                    je     0x37       (1st 'if' in
>>>> sctp_v4_cmp_addr)
>>>>    30:    31 c0                    xor    %eax,%eax
>>>>    32:    c9                       leaveq
>>>>    33:    c3                       retq
>>>>    34:    0f 1f 00                 nopl   (%rax)
>>>>    37:    0f b7 47 02              movzwl 0x2(%rdi),%eax
>>>>    ...
>>>>
>>>> There have been some approaches to fix corruptions with the same or
>>>> very similar stack trace such as 2eebc1e ("sctp: Fix list corruption
>>>> resulting from freeing an association on a list"), 0b0fe913 ("sctp:
>>>> proc: protect bind_addr->address_list accesses with rcu_read_lock()"),
>>>> 45122ca ("sctp: Add RCU protection to assoc->transport_addr_list")
>>>> that are all important fixes, but the panic still can occur in some
>>>> cases with such a stack trace above.
>>>>
>>>> When entering into sctp_seq_dump_local_addrs(), the sctp_ep_common
>>>> structure is correctly of type SCTP_EP_TYPE_ASSOCIATION, and has a
>>>> refcnt of 1 and dead is 0. Also from kdump, the ebp's pointer members
>>>> do not look corrupted. When entering sctp_v4_cmp_addr(), the first
>>>> sctp_addr argument looks good/valid, but the second sctp_addr argument
>>>> ('primary') is 0000000000000078 and results suddenly in a NULL pointer
>>>> _dereference_ in sctp_v4_cmp_addr() although in the test before it
>>>> seems to have been "primary != NULL".
>>>>
>>>> Now, how can this happen? Let's assume asoc->peer.primary_path is NULL
>>>> which is possible to happen.

This is an invalid assumption.  An association without a primary path 
must not be reachable through the association hash list.

>>>> Here, we do not check for it, but take the
>>>> address (note we do not actually dereference it!) of its saddr member.
>>>> This is then exactly 0000000000000078 as reported in the trace, since
>>>> that is equal to the offset of saddr from the primary_path container
>>>> (in the reported kernel). Thus, the check for NULL (== (void *) 0) will
>>>> pass, eventually leading to the NULL pointer dereference in cmp_addr()
>>>> since this address is within the NULL page.
>>>>
>>>> Lets fix it by being paranoid and checking first if our primary
>>>> transport
>>>> is != NULL and in case of != NULL if it is alive. Then, let us hold a
>>>> copy of the sctp_addr on the stack instead of using a pointer just in
>>>> case the transport could be destroyed at a later point in time
>>>> (we're not
>>>> in a hurry anyway). By that, we can avoid this very scenario, only just
>>>> for the sake of printing this asterisk and can fix the NULL pointer
>>>> dereference eventually. Introduced by bca735bd ("Extend the info
>>>> exported
>>>> via /proc/net/sctp to support netstat for SCTP.").
>>>>
>>> First off, nice analysis Daniel, that very clear and consice.  The
>>> patch below
>>> makes sense to me, but I'm getting the impression that, if we need to
>>> use the
>>> dead flag here, that rcu_locking isn't going to be safe. If we aren't
>>> guaranteed
>>> that saddr is going to be a valid pointer or NULL, and as a
>>> consequence are
>>> going to need to rely on the ->dead flag, then we have a potential race
>>> condition to worry about.  I think the transport pointer is safe
>>> here, as its
>>> rcu protected in the free path, but its parent association is not.
>>> By getting
>>> the assocation that a given trasport points to, we risk a race with the
>>> destruction of that association (I think).  We probably need to
>>> convert the
>>> association create/free paths (as well as the endpoint, etc,
>>> create/free paths),
>>> to be rcu sensitive, but for the time being, it may be sufficient to
>>> simply hold
>>> the association in sctp_seq_dump_local_addrs.
>>
>> Well, checking for ->dead might be unnecessary and can probably be
>> deleted (if wished
>> I can do that and resubmit).
>>
>> At the time of the crash, the association was in SCTP_STATE_CLOSED and
>> the pointer to
>> primary_path in fact NULL.
>>
>> The association looks as follows:
>>
>> crash> sctp_association ffff880c27d9d800 |grep primary_path
>>      primary_path = 0x0,
>
> Probably this could be the case of a SCTP TCP-style socket that is still
> around, but
> eventually removed in sctp_close():
>
>      if (sctp_style(sk, TCP)) {
>          /* A closed association can still be in the list if
>           * it belongs to a TCP-style listening socket that is
>           * not yet accepted. If so, free it. If not, send an
>           * ABORT or SHUTDOWN based on the linger options.
>           */
>          if (sctp_state(asoc, CLOSED)) {
>              sctp_unhash_established(asoc);
>              sctp_association_free(asoc);
>              continue;
>          }
>      }
>
> This would explain the SCTP_STATE_CLOSED of the association.

No, that's not it.  sctp_association_free() is the one that frees all 
the transports and bind addresses, and that doesn't happen for tcp-style
associations that have been closed on a listening socket.  Thus the 
transports should all still be set.

In fact, a association without transports must never be on the 
association hash chain (or linked to endpoint).  It must not be reached
as it is not fully initialized.  We've had a bug before where we
incorrectly used SCTP_CMD_NEW_ASSOC command just so we can delete the
association.  In a circumstance where all we are trying to do is destroy
a new association, we should be using SCTP_CMD_SET_ASOC.

I had a quick look at this seems to be fixed upstream.

-vlad


> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
