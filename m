From: Alessio Igor Bogani <abogani-c2gU+FDvWfqonA0d6jMUrA@public.gmane.org>
Subject: Re: [tree] latest kill-the-BKL tree, v12
Date: Thu, 16 Apr 2009 16:35:58 +0200
Message-ID: <63a49ef40904160735w3eab9ea7s3fc5da177ee2ac87@mail.gmail.com>
References: <1239680065-25013-1-git-send-email-fweisbec@gmail.com>
	 <20090414045109.GA26908@orion> <20090414090146.GH27003@elte.hu>
	 <a4423d670904151558r4252c7eamd115793fb36a9163@mail.gmail.com>
	 <20090415230736.GA22710@elte.hu> <20090415233533.GA5962@nowhere>
	 <20090416085153.GC9813@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>,
	ReiserFS Development List <reiserfs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090416085153.GC9813-X9Un+BFzKDI@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Sir Molnar,

2009/4/16 Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>:
[...]
>> This is still the dependency between bkl and s_umount_key that has
>> been reported recently. I wonder if this is not a problem in the
>> fs layer. I should investigate on it.
>
> The problem seem to be that this NFS call context:
>
> -> #0 (kernel_mutex){+.+.+.}:
> =A0 =A0 =A0 [<00000000004776d0>] lock_acquire+0x5c/0x74
> =A0 =A0 =A0 [<00000000006f0ebc>] mutex_lock_nested+0x48/0x380
> =A0 =A0 =A0 [<00000000006f32dc>] lock_kernel+0x28/0x3c
> =A0 =A0 =A0 [<00000000006d20ec>] rpc_wait_bit_killable+0x64/0x8c
> =A0 =A0 =A0 [<00000000006f0620>] __wait_on_bit+0x64/0xc0
> =A0 =A0 =A0 [<00000000006f06e4>] out_of_line_wait_on_bit+0x68/0x7c
> =A0 =A0 =A0 [<00000000006d2938>] __rpc_execute+0x150/0x2b4
> =A0 =A0 =A0 [<00000000006d2ac0>] rpc_execute+0x24/0x34
> =A0 =A0 =A0 [<00000000006cc338>] rpc_run_task+0x64/0x74
> =A0 =A0 =A0 [<00000000006cc474>] rpc_call_sync+0x58/0x7c
> =A0 =A0 =A0 [<00000000005717b0>] nfs3_rpc_wrapper+0x24/0xa0
> =A0 =A0 =A0 [<0000000000572024>] do_proc_get_root+0x6c/0x10c
> =A0 =A0 =A0 [<00000000005720dc>] nfs3_proc_get_root+0x18/0x5c
> =A0 =A0 =A0 [<000000000056401c>] nfs_get_root+0x34/0x17c
> =A0 =A0 =A0 [<0000000000568adc>] nfs_get_sb+0x9ec/0xa7c
> =A0 =A0 =A0 [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
> =A0 =A0 =A0 [<00000000004b7f84>] do_kern_mount+0x30/0xcc
> =A0 =A0 =A0 [<00000000004cf300>] do_mount+0x7c8/0x80c
> =A0 =A0 =A0 [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
> =A0 =A0 =A0 [<0000000000406154>] linux_sparc_syscall32+0x34/0x40

Proposed patch that i just sent
(http://marc.info/?l=3Dlinux-kernel&m=3D123989213917572&w=3D2) seems fi=
x the
lock dependency.
I don't know if it is the right way to solve the problem in any case
but it works on my laptop, at least.

Ciao,
Alessio
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
