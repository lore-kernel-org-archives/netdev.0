From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc1 fails with lockup - /sbin/ifconfig / inet_ioctl() /
	dev_close() / rtl8169_down()
Date: Fri, 26 Oct 2007 08:37:33 +0200
Message-ID: <20071026063733.GA12426@elte.hu>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org> <1193232344.32208.0.camel@localhost> <20071024142759.GA13657@elte.hu> <1193241191.14314.8.camel@localhost> <20071024155521.GA16690@elte.hu> <1193242267.6914.6.camel@twins> <1193378269.17910.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Romano Giannetti <romanol@upcomillas.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50553 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbXJZGiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 02:38:08 -0400
Content-Disposition: inline
In-Reply-To: <1193378269.17910.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Romano Giannetti <romanol@upcomillas.es> wrote:

> > Does this help?
> 
> I tried this, but although I have the D-state processes, I cannot see 
> any debug trace now. Results are at:
> 
> http://www.dea.icai.upcomillas.es/romano/linux/info/2624rc1_3/
> 
> Can I try anything more? This is quite a show-stopper for me... and 
> before trying to bisect 11Mbyte of patches...

hm, from your log it appears that lockdep did not find anything, still 
the hang does trigger.

it's /sbin/ifconfig and inet_ioctl() / dev_close() / rtl8169_down() that 
seems to be hanging. I've extracted the relevant backtrace below. I've 
Cc:-ed people who might have a better idea about what's going on.

	Ingo

 ------------------>
 ifconfig      S c0476f80     0  7226   7166
        cbb67df0 00000046 c02f3f97 c0476f80 cbb67dc0 c01489d5 c2b81550 c2b8168c 
        c1cf7b80 00000000 c30bd250 00000000 cbb67dd0 00000282 cbb67e00 c0476f80 
        cbb67df0 c0132618 00004232 00000000 00000282 cbb67e00 00004232 f884e000 
 Call Trace:
  [schedule_timeout+72/192] schedule_timeout+0x48/0xc0
  [schedule_timeout_interruptible+21/32] schedule_timeout_interruptible+0x15/0x20
  [msleep_interruptible+39/64] msleep_interruptible+0x27/0x40
  [<f88422f0>] rtl8169_down+0xb0/0xd0 [r8169]
  [<f88424cf>] rtl8169_close+0x1f/0xb0 [r8169]
  [dev_close+71/96] dev_close+0x47/0x60
  [dev_change_flags+125/384] dev_change_flags+0x7d/0x180
  [devinet_ioctl+1225/1632] devinet_ioctl+0x4c9/0x660
  [inet_ioctl+107/144] inet_ioctl+0x6b/0x90
  [sock_ioctl+208/544] sock_ioctl+0xd0/0x220
  [do_ioctl+40/128] do_ioctl+0x28/0x80
  [vfs_ioctl+87/640] vfs_ioctl+0x57/0x280
  [sys_ioctl+57/96] sys_ioctl+0x39/0x60
  [sysenter_past_esp+95/165] sysenter_past_esp+0x5f/0xa5
  =======================
