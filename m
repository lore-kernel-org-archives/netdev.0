From: Jarek Poplawski <jarkao2@gmail.com>
Subject: hrtimers lockups Re: NMI lockup, 2.6.26 release
Date: Sat, 26 Jul 2008 00:31:22 +0200
Message-ID: <20080725223121.GD3107@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200807240256.36098.denys@visp.net.lb> <20080725073628.GA10399@ff.dom.local> <200807260009.52838.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:38584 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbYGYW3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 18:29:05 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2878501ika.5
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 15:29:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807260009.52838.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This netdev thread describes lockups breaking in hrtimers code:

http://marc.info/?l=linux-netdev&m=121675217927170&w=2

Very similar reports from Denys Fedoryshchenko could be found in
netdev archives a few kernel versions before.

It looks like replacing hrtimers with timers in sch_htb code removes
problems. I hope, Thomas or somebody from linux-kernel could give
some clue on this.

Thanks,
Jarek P.

Denys, read below:

On Sat, Jul 26, 2008 at 12:09:52AM +0300, denys@visp.net.lb wrote:
> I will try to explain all details, maybe anything matter
> 
> around 150-300 megs passing
> Core 2 Duo E6750
> 3 ifb's
> 29 htb classes (summary)
> 26 qdiscs (sfq and bfifo)
> NAT is running (465-700K connections)
> maximum bfifo qdisc size is 600Kbyte
> mostly all filters u32 (one is police mtu)
> quantum is 1514, one is 1515
> Load is low (below 30-35)% by mpstat
> 
> The only error i have in dmesg (a LOT of this messages, different ip port, )
> [162014.265116] UDP: short packet: From 200.122.35.205:64599 8409/1480 to 
> 213.254.233.9:6073
> [162014.373110] UDP: short packet: From 200.122.35.205:52015 10698/1480 to 
> 213.254.233.9:4855
> 
> [162088.232099] UDP: bad checksum. From 96.234.33.9:1077 to 
> 213.254.233.9:49520 ulen 111
> 
> 
> I run time-warp-test from Ingo Molnar - nothing, no warps.
> 
> If required - i can send all rules to private e-mail.
> 
> I will apply patch after 30-60 minutes (off peak time). Thanks for help a lot!

You are very helpful too! But, I think we will need some help from
hrtimers/hardware gurus. IMHO, since it works with timers, the bug
doesn't seem to belong to "netdev". I can't see any obvious
possibility of "abusing" hrtimers with e.g. too big number of hrtimers
with your config (1 hrtimer per qdisc). So, I'm not very optimistic
about this new patch, but even if it works it looks like something
else is wrong. That's why I added some CC to this.

Jarek P.
