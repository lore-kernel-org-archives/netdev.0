From: thunder7@xs4all.nl
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Sun, 2 Sep 2007 07:36:11 +0200
Message-ID: <20070902053611.GA12508@amd64.of.nowhere>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org> <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, thunder7@xs4all.nl,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758379AbXIBFgb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>
Date: Sun, Sep 02, 2007 at 06:24:29AM +0530
> 
> The dmesg you posted below doesn't cover the messages from this oops
> itself. As you mentioned you can reproduce this oops easily, please do so,
> and post the *full* oops log (if it doesn't get logged to disk, you can
> try taking digicam photo, or write down *all* the messages and post here).
> I built an x86_64 kernel as per your .config, but don't see any memory
> dereference at nv_napi_poll+0x108 -- could be toolchain differences.
> 
> Else, can you run:
> $ gdb ./vmlinux
> 
> and then:
> (gdb) l *nv_napi_poll+0x108
> 
> and send us the output?
> 
That seems to be the easier option:

AMD64 :gdb /usr/src/linux-2.6.23-rc4-mm1/vmlinux
GNU gdb 6.6-debian
(gdb) l *nv_napi_poll+0x108
0xffffffff80418f28 is in nv_napi_poll (drivers/net/forcedeth.c:2470).
2465				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
2466					skb->ip_summed = CHECKSUM_UNNECESSARY;
2467				} else {
2468					if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
2469					    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
2470						skb->ip_summed = CHECKSUM_UNNECESSARY;
2471					}
2472				}
2473	
2474				/* got a valid packet - forward it to the network core */
(gdb) q

as for toolchain differences: this is Debian Unstable, up-to-date as of
yesterday morning.

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux middle 2.6.23-rc1-mm2 #1 SMP Wed Aug 1 14:58:22 CEST 2007 x86_64 GNU/Linux
 
Gnu C                  4.1.3
Gnu make               3.81
binutils               Binutils
util-linux             2.13
mount                  2.13
module-init-tools      3.3-pre11
e2fsprogs              1.40.2
reiserfsprogs          3.6.19
Linux C Library        6.1
Dynamic linker (ldd)   2.6.1
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
Modules Loaded         nf_nat_ftp nf_nat_irc nf_conntrack_irc nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT ipt_LOG xt_limit nf_conntrack_ipv4 xt_state xt_tcpudp iptable_filter ip_tables x_tables snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_emul snd_emu10k1 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_rawmidi snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_device snd_timer snd_page_alloc snd_util_mem snd_hwdep snd soundcore k8temp it87 hwmon_vid hwmon i2c_nforce2

Good luck,
Jurriaan
-- 
His pride could withstand anything. He simply wouldn't care.
	Melanie Rawn - Skybowl
Debian (Unstable) GNU/Linux 2.6.23-rc1-mm2 2x2010 bogomips load 0.43
the Jack Vance Integral Edition: http://www.integralarchive.org
