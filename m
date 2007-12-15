From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc5-mm1 -- inconsistent {in-softirq-W} -> {softirq-on-R}
 usage.
Date: Fri, 14 Dec 2007 21:58:51 -0800
Message-ID: <20071214215851.4719b631.akpm@linux-foundation.org>
References: <a44ae5cd0712141413u4ddbfd06gca259cfc3bc0ab1a@mail.gmail.com>
	<20071214153633.5d8f609a.akpm@linux-foundation.org>
	<a44ae5cd0712141958o10d9a320h3b8173019ac6b0eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Ingo Molnar" <mingo@elte.hu>,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>
To: "Miles Lane" <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54848 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636AbXLOF7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 00:59:49 -0500
In-Reply-To: <a44ae5cd0712141958o10d9a320h3b8173019ac6b0eb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 22:58:24 -0500 "Miles Lane" <miles.lane@gmail.com> =
wrote:

> On Dec 14, 2007 6:36 PM, Andrew Morton <akpm@linux-foundation.org> wr=
ote:
> > On Fri, 14 Dec 2007 17:13:21 -0500
> > "Miles Lane" <miles.lane@gmail.com> wrote:
> >
> >
> > > Sorry Andrew, I don't know who to forward this problem to.
> > >
> > > I tried running:  find /proc | xargs cat
> > > and got this:
> > >
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > [ INFO: inconsistent lock state ]
> > > 2.6.24-rc5-mm1 #26
> > > ---------------------------------
> > > inconsistent {in-softirq-W} -> {softirq-on-R} usage.
> > > cat/6944 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > BUG: unable to handle kernel paging request at virtual address 0f=
1eff0b
> > > printing ip: c01fe64d *pde =3D 00000000
> > > Oops: 0000 [#1] PREEMPT SMP
> > > last sysfs file: /sys/block/sda/sda3/stat
> > > Modules linked in: aes_generic i915 drm rfcomm l2cap bluetooth
> > > cpufreq_stats cpufreq_conservative cpufreq_performance sbs sbshc
> > > dm_crypt sbp2 parport_pc lp parport pcmcia arc4 ecb crypto_blkcip=
her
> > > cryptomgr crypto_algapi tifm_7xx1 tifm_core yenta_socket
> > > rsrc_nonstatic pcmcia_core iwl3945 iTCO_wdt iTCO_vendor_support
> > > watchdog_core watchdog_dev snd_hda_intel mac80211 snd_pcm_oss
> > > snd_mixer_oss cfg80211 snd_pcm sky2 snd_seq_dummy snd_seq_oss
> > > snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer
> > > snd_seq_device snd soundcore snd_page_alloc shpchp pci_hotplug
> > > firewire_ohci firewire_core crc_itu_t ata_generic piix ide_core
> > >
> > > Pid: 6944, comm: cat Not tainted (2.6.24-rc5-mm1 #26)
> > > EIP: 0060:[<c01fe64d>] EFLAGS: 00210097 CPU: 0
> > > EIP is at strnlen+0x9/0x1c
> > > EAX: 0f1eff0b EBX: 0f1eff0b ECX: 0f1eff0b EDX: fffffffe
> > > ESI: c05b74f6 EDI: d6267d94 EBP: d6267cc8 ESP: d6267cc8
> > >  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > > Process cat (pid: 6944, ti=3Dd6267000 task=3Dd5a09000 task.ti=3Dd=
6267000)
> > > Stack: d6267cfc c01fdd22 00000400 c05b74f4 00000001 c05b78f4 0000=
0000 ffffffff
> > >        ffffffff c048f503 00000400 d5a09000 00000002 d6267d0c c01f=
df41 d6267d94
> > >        db68c04a d6267d74 c012ae81 d6267d94 00000028 c05b89f7 0020=
0046 00000000
> > > Call Trace:
> > >  [<c0108eb2>] show_trace_log_lvl+0x12/0x25
> > >  [<c0108f4f>] show_stack_log_lvl+0x8a/0x95
> > >  [<c0108fe4>] show_registers+0x8a/0x1bd
> > >  [<c010922f>] die+0x118/0x1dc
> > >  [<c03cf706>] do_page_fault+0x5a4/0x681
> > >  [<c03cdd72>] error_code+0x72/0x78
> > >  [<c01fdd22>] vsnprintf+0x277/0x40e
> > >  [<c01fdf41>] vscnprintf+0xe/0x1d
> > >  [<c012ae81>] vprintk+0xcb/0x2f3
> > >  [<c012b0be>] printk+0x15/0x17
> > >  [<c0145e55>] print_lock_name+0x4e/0xa2
> > >  [<c0146099>] print_lock+0xe/0x3a
> > >  [<c01464cf>] print_usage_bug+0xbc/0x117
> > >  [<c0146fb6>] mark_lock+0x2e7/0x3fe
> > >  [<c0147b9a>] __lock_acquire+0x498/0xbf4
> > >  [<c014836c>] lock_acquire+0x76/0x9d
> > >  [<c03cd6d2>] _read_lock+0x23/0x32
> > >  [<c03491ae>] sock_i_ino+0x14/0x30
> > >  [<c03c88ed>] packet_seq_show+0x22/0x75
> > >  [<c019b41a>] seq_read+0x19d/0x26f
> > >  [<c01b0ded>] proc_reg_read+0x60/0x74
> > >  [<c01854aa>] vfs_read+0x8a/0x106
> > >  [<c01858a8>] sys_read+0x3b/0x60
> > >  [<c0107cea>] sysenter_past_esp+0x6b/0xc1
> > >  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> > > Code: 01 00 00 00 4f 89 fa 5f 89 d0 5d c3 55 85 c9 89 e5 57 89 c7=
 89
> > > d0 74 05 f2 ae 75 01 4f 89 f8 5f 5d c3 55 89 c1 89 e5 89 c8 eb 06=
 <80>
> > > 38 00 74 07 40 4a 83 fa ff 75 f4 29 c8 5d c3 90 90 90 55 83
> > > EIP: [<c01fe64d>] strnlen+0x9/0x1c SS:ESP 0068:d6267cc8
> > > note: cat[6944] exited with preempt_count 4
> >
> > I'd say you hit a networking locking bug and then when trying to re=
port
> > that bug, lockdep crashed.
> >
> > The networking bug looks to be around sock_i_ino()'s taking of
> > sk_callback_lock with softirq's enabled.  Perhaps this will fix it.
> >
> > diff -puN net/core/sock.c~a net/core/sock.c
> > --- a/net/core/sock.c~a
> > +++ a/net/core/sock.c
> > @@ -1115,9 +1115,9 @@ int sock_i_uid(struct sock *sk)
> >  {
> >         int uid;
> >
> > -       read_lock(&sk->sk_callback_lock);
> > +       read_lock_bh(&sk->sk_callback_lock);
> >         uid =3D sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : =
0;
> > -       read_unlock(&sk->sk_callback_lock);
> > +       read_unlock_bh(&sk->sk_callback_lock);
> >         return uid;
> >  }
> >
> > @@ -1125,9 +1125,9 @@ unsigned long sock_i_ino(struct sock *sk
> >  {
> >         unsigned long ino;
> >
> > -       read_lock(&sk->sk_callback_lock);
> > +       read_lock_bh(&sk->sk_callback_lock);
> >         ino =3D sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_ino : =
0;
> > -       read_unlock(&sk->sk_callback_lock);
> > +       read_unlock_bh(&sk->sk_callback_lock);
> >         return ino;
> >  }
> >
> > _
> >
> >
>=20
> I applied the patch and then tried my test again.  This time my syste=
m
> locked up.
> Perhaps I should open a new thread for this, since the problem looks
> pretty different.
>=20
> Dec 14 21:32:55 feargod kernel: process `cat' is using deprecated
> sysctl (syscall) net.ipv6.neigh.default.retrans_time; Use
> net.ipv6.neigh.default.retran
> s_time_ms instead.
> Dec 14 21:32:55 feargod kernel:
> Dec 14 21:32:55 feargod kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Dec 14 21:32:55 feargod kernel: [ BUG: bad unlock balance detected! ]
> Dec 14 21:32:55 feargod kernel: -------------------------------------
> Dec 14 21:32:55 feargod kernel: cat/6180 is trying to release lock
> (kkkkkkk=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDH3=EF=BF=BD=EF=BF=
=BD) at:
> Dec 14 21:32:55 feargod kernel: [packet_seq_stop+0xe/0x10]
> packet_seq_stop+0xe/0x10
> Dec 14 21:32:55 feargod kernel: but there are no more locks to releas=
e!
> Dec 14 21:32:55 feargod kernel:
> Dec 14 21:32:55 feargod kernel: other info that might help us debug t=
his:
> Dec 14 21:32:55 feargod kernel: 2 locks held by cat/6180:
> Dec 14 21:32:55 feargod kernel:  #0:  (&p->lock){--..}, at:
> [crypto_algapi:seq_read+0x25/0x191c1] seq_read+0x25/0x26f
> Dec 14 21:32:55 feargod kernel:  #1:
> (&net->packet.sklist_lock){-.--}, at: [packet_seq_start+0x14/0x4d]
> packet_seq_start+0x14/0x4d
> Dec 14 21:32:55 feargod kernel:
> Dec 14 21:32:55 feargod kernel: stack backtrace:
> Dec 14 21:32:55 feargod kernel: Pid: 6180, comm: cat Not tainted
> 2.6.24-rc5-mm1 #27
> Dec 14 21:32:55 feargod kernel:  [show_trace_log_lvl+0x12/0x25]
> show_trace_log_lvl+0x12/0x25
> Dec 14 21:32:55 feargod kernel:  [show_trace+0xd/0x10] show_trace+0xd=
/0x10
> Dec 14 21:32:55 feargod kernel:  [sbp2:dump_stack+0x57/0x17a1]
> dump_stack+0x57/0x5f
> Dec 14 21:32:55 feargod kernel:
> [print_unlock_inbalance_bug+0xce/0xd8]
> print_unlock_inbalance_bug+0xce/0xd8
> Dec 14 21:32:55 feargod kernel:  [lock_release_non_nested+0x89/0x13b]
> lock_release_non_nested+0x89/0x13b
> Dec 14 21:32:55 feargod kernel:  [mac80211:lock_release+0x186/0x5065]
> lock_release+0x186/0x1b6
> Dec 14 21:32:55 feargod kernel:  [snd_seq:_read_unlock+0x16/0x3d]
> _read_unlock+0x16/0x3d
> Dec 14 21:32:55 feargod kernel:  [packet_seq_stop+0xe/0x10]
> packet_seq_stop+0xe/0x10
> Dec 14 21:32:55 feargod kernel:
> [crypto_algapi:seq_read+0x1d4/0x191c1] seq_read+0x1d4/0x26f
> Dec 14 21:32:55 feargod kernel:  [proc_reg_read+0x60/0x74]
> proc_reg_read+0x60/0x74
> Dec 14 21:32:55 feargod kernel:  [vfs_read+0x8a/0x106] vfs_read+0x8a/=
0x106
> Dec 14 21:32:55 feargod kernel:  [sys_read+0x3b/0x60] sys_read+0x3b/0=
x60
> Dec 14 21:32:55 feargod kernel:  [sysenter_past_esp+0x6b/0xc1]

ugly.  At a guess I'd say the code in there has got a hold of some
corrupted/garbage memory when it thinks it has a struct sock*.

Do you have a recipe which others might use to reproduce this?

<waves vigorously at net developers>

