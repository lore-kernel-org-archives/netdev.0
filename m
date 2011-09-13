From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: 3.1-rc4: spectacular kernel errors / filesystem crash
Date: Mon, 12 Sep 2011 20:59:38 -0700
Message-ID: <CAEuXFEzs1f7n5taYzupux3AtKmRcY4P0m7yjkUQA8aLyS8eujw@mail.gmail.com>
References: <alpine.DEB.2.02.1109110511250.8626@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
	Alan Piszcz <ap@solarrain.com>,
	NetDEV list <netdev@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45603 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab1IMD7k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 23:59:40 -0400
In-Reply-To: <alpine.DEB.2.02.1109110511250.8626@p34.internal.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

added netdev because it appears to start with an igb tx hang

On Sun, Sep 11, 2011 at 2:40 AM, Justin Piszcz <jpiszcz@lucidpixels.com=
> wrote:
> Hi,
>
> Over the past 24-48 hours I was running some CPU-intenstive jobs and =
there
> was heavy I/O on the RAID (9750-24i4e + a RAID6)..
>
> I believe most of the problem started when I included many kernel opt=
ions as
> modules (before I only compiled in [*] the drivers I used), there app=
ears to
> have something to gone awry in the kernel and then afterwards, disks =
started
> going in and out, XFS shut down, etcera.
>
> I'm opening a case with LSI to see what happened with the 3ware card;
> however, after a power cycle, everything came back OK (the drives and=
 HW) is
> physically OK, it is rebuilding onto those two drives with CFG-OP-FAI=
L but
> other than that, everything 'seems' OK, still need to do an fsck.
>
> Something went wrong in the kernel and caused a cascading effect of e=
rrors,
> this occurred (I believe) when I started to run a lot of encoding job=
s;
> however, I was doing a lot of data transfer for the past 24-48 hours =
on the
> RAID array, the system (separate SSD/EXT4) remained unaffected but ot=
her
> weird stuff happened as well..
>
> I still see these in the logs as well after the reboot (not often; bu=
t e.g.,
> the RAID controller is rebuilding from the two drives with CFG-OPT-FA=
IL (the
> physical drives are 100% healthy):
>
> [ 1062.925904] 3w-sas 0000:83:00.0: vpd r/w failed. =A0This is likely=
 a
> firmware bug on this device. =A0Contact the card vendor for a firmwar=
e update.
>
> So, my plan:
>
> 1. Report this error to LKML+XFS mailing lists.
> 2. Open case with LSI support.
> 3. Recompile the kernel how I used for many years [only compile in op=
tions
> =A0 that you need [*] and do not compile drivers as modules]
> 4. Reboot Linux systems and see if this recurs again under the same
> =A0 workload, after the RAID is done rebuilding.
>
> --
>
> So these errors are quite long, will upload to HTTP and paste the rel=
evant
> bits below.
>
> --
>
> URLs for FULL logs:
>
> 1. tw_cli /cX show diag:
> =A0 http://home.comcast.net/~jpiszcz/20110911/show_diag.txt
>
> 2. Full kernel log (and previous morning of kernel crash)
> =A0 http://home.comcast.net/~jpiszcz/20110911/kern.log.txt
>
> 3. tw_cli /cX show all
> =A0 http://home.comcast.net/~jpiszcz/20110911/cfg-fail.txt
>
> --
>
> Summary (what seems to have occurred, have not done a full analysis y=
et)
>
> 1. 3ware card freaked out due to kernel/RCU/APIC(?) errors
>
> 2. Then, the time source went unstable (this happens with weird kerne=
l bugs
> =A0 on many different hosts, I have seen this over time).
>
> 3. Then, on the 3ward carde, drives started leaving and being re-inse=
rted
> =A0 by themsevles, XFS went off-line to protect the filesystem due to=
 the
> =A0 3ware issues
>
> --
>
> 3ware/RAID-- Interesting errors:
>
> I've never seen this before on a 3ware RAID controller, at least from=
 what
> I can remember and I've been using 3ware cards for many years..
>
> p2 =A0 =A0CFG-OP-FAIL =A0 =A0- =A0 =A02.73 TB =A0 SATA =A02 =A0 - =A0=
 =A0 =A0 =A0 =A0 =A0Hitachi
> HDS723030AL p3 =A0 =A0CFG-OP-FAIL =A0 =A0- =A0 =A02.73 TB =A0 SATA =A0=
3 =A0 -
> =A0Hitachi HDS723030AL
>
> --
>
> Kernel/ERRORS:
>
> FWIW it all seem to start during an encoding job around 21:00:
>
> Sep 10 18:00:00 p34 kernel: [520427.143054] ixgbe 0000:03:00.0: eth6:=
 NIC
> Link is Down
> Sep 10 19:20:04 p34 kernel: [525223.256098] 3w-sas: scsi1: AEN: INFO
> (0x04:0x002B): Verify completed:unit=3D0.
> Sep 10 20:59:39 p34 kernel: [531189.671361] ------------[ cut here
> ]------------
> Sep 10 20:59:39 p34 kernel: [531189.671376] WARNING: at
> net/sched/sch_generic.c:255 dev_watchdog+0x23f/0x250()
> Sep 10 20:59:39 p34 kernel: [531189.671378] Hardware name: X8DTH-i/6/=
iF/6F
> Sep 10 20:59:39 p34 kernel: [531189.671380] NETDEV WATCHDOG: eth1 (ig=
b):
> transmit queue 5 timed out
> Sep 10 20:59:39 p34 kernel: [531189.671382] Modules linked in: dm_mod
> tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_us=
b_audio
> snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmid=
i_lib
> snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
> snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial j=
oydev
> serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi=
 wmi
> i7core_edac edac_core video
> Sep 10 20:59:39 p34 kernel: [531189.671414] Pid: 83, comm: ksoftirqd/=
19 Not
> tainted 3.1.0-rc4 #1
> Sep 10 20:59:39 p34 kernel: [531189.671415] Call Trace:
> Sep 10 20:59:39 p34 kernel: [531189.671424] =A0[<ffffffff810379ba>]
> warn_slowpath_common+0x7a/0xb0
> Sep 10 20:59:39 p34 kernel: [531189.671427] =A0[<ffffffff81037a91>]
> warn_slowpath_fmt+0x41/0x50
> Sep 10 20:59:39 p34 kernel: [531189.671433] =A0[<ffffffff815d7874>] ?
> schedule+0x2e4/0x950
> Sep 10 20:59:39 p34 kernel: [531189.671436] =A0[<ffffffff814e5aff>]
> dev_watchdog+0x23f/0x250
> Sep 10 20:59:39 p34 kernel: [531189.671440] =A0[<ffffffff81043872>]
> run_timer_softirq+0xf2/0x220
> Sep 10 20:59:39 p34 kernel: [531189.671443] =A0[<ffffffff814e58c0>] ?
> qdisc_reset+0x50/0x50
> Sep 10 20:59:39 p34 kernel: [531189.671446] =A0[<ffffffff8103d208>]
> __do_softirq+0x98/0x120
> Sep 10 20:59:39 p34 kernel: [531189.671448] =A0[<ffffffff8103d345>]
> run_ksoftirqd+0xb5/0x160
> Sep 10 20:59:39 p34 kernel: [531189.671454] =A0[<ffffffff8103d290>] ?
> __do_softirq+0x120/0x120
> Sep 10 20:59:39 p34 kernel: [531189.671458] =A0[<ffffffff810523b7>]
> kthread+0x87/0x90
> Sep 10 20:59:39 p34 kernel: [531189.671462] =A0[<ffffffff815dbdb4>]
> kernel_thread_helper+0x4/0x10
> Sep 10 20:59:39 p34 kernel: [531189.671465] =A0[<ffffffff81052330>] ?
> kthread_worker_fn+0x130/0x130
> Sep 10 20:59:39 p34 kernel: [531189.671467] =A0[<ffffffff815dbdb0>] ?
> gs_change+0xb/0xb
> Sep 10 20:59:39 p34 kernel: [531189.671468] ---[ end trace 553dfe731f=
ce91ba
> ]---
> Sep 10 20:59:39 p34 kernel: [531189.671478] igb 0000:01:00.1: eth1: R=
eset
> adapter
> Sep 10 20:59:42 p34 kernel: [531192.826058] igb: eth1 NIC Link is Up =
1000
> Mbps Full Duplex, Flow Control: RX/TX
> Sep 10 21:00:00 p34 kernel: [531210.034506] BUG: soft lockup - CPU#0 =
stuck
> for 22s! [kswapd0:947]
>
> --
>
> URLs for FULL logs:
>
> 1. tw_cli /cX show diag:
> =A0 http://home.comcast.net/~jpiszcz/20110911/show_diag.txt
>
> 2. Full kernel log (and previous morning of kernel crash)
> =A0 http://home.comcast.net/~jpiszcz/20110911/kern.log.txt
>
> 3. tw_cli /cX show all
> =A0 http://home.comcast.net/~jpiszcz/20110911/cfg-fail.txt
>
> --
>
> Currently...
>
> After all of this happened, I stopped all I/O on the system/all proce=
sses,
> etc
> I shutdown the host, removed the power, powered it back up, now the d=
rives
> that showed CFG-OP-FAIL before now show as REBUILDING, I am waiting f=
or them
> to rebuild before doing anything else.
>
> Justin.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
