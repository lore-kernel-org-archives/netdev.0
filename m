From: Michael Brade <brade@informatik.uni-muenchen.de>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Wed, 14 Sep 2011 23:36:16 +0200
Message-ID: <201109142336.17291.brade@informatik.uni-muenchen.de>
References: <201108141308.28140.kjun-chen@sambodha.org> <201109112216.33579.brade@informatik.uni-muenchen.de> <20110913081126.GA20022@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:40256 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933341Ab1INVgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 17:36:20 -0400
In-Reply-To: <20110913081126.GA20022@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 September 2011 10:11:26 you wrote:
> Michael Brade <brade@informatik.uni-muenchen.de> :
> [...]
> 
> > Does it have to be 3.1.0-rc3 or is 3.0.1 ok as well ?
> :
> :o(
> 
> Almost any release may exhibit the bug. The attached patch (#0003)
> should be a better candidate as an official fix though.

ok, good news: I did not experience any freeze anymore even though I 
transfered 60 GB. And I applied both of your patches and 

-                   if (status & RxFOVF) {
-                           rtl8169_schedule_work(dev, rtl8169_reset_task);
-                           dev->stats.rx_fifo_errors++;
-                   }

 
> > If so, I have another bad news: 3.0.1 still crashes with this patch.
> > It took me a lot longer to crash it but eventually it did happen.
> > Not sure why it took longer, I guess I didn't generate enough throughput.
> 
> It sure sucks from a user experience viewpoint but it is not _that_ bad.

I disagree - I actually lose data because I mount my data and backups with 
iSCSI and exactly then it crashes.

> Are the symptoms in any way different or do you still notice more-or-less
> periodic link-up messages and no real network traffic ?

dmesg looks like this:

[ 1611.380420] r8169 0000:13:00.0: eth0: link up
[ 1611.995417] r8169 0000:13:00.0: eth0: link up
[ 1612.323050] r8169 0000:13:00.0: eth0: link up
[ 1612.574016] r8169 0000:13:00.0: eth0: link up
[ 1613.450630] r8169 0000:13:00.0: eth0: link up
[ 1613.929383] r8169 0000:13:00.0: eth0: link up
[ 1614.950939] r8169 0000:13:00.0: eth0: link up
[ 1615.699660] r8169 0000:13:00.0: eth0: link up
[ 1616.005507] r8169 0000:13:00.0: eth0: link up
[ 1616.746199] r8169 0000:13:00.0: eth0: link up
[ 1617.879670] r8169 0000:13:00.0: eth0: link up
[ 1618.461433] r8169 0000:13:00.0: eth0: link up

so yes but what do you mean with "no real network traffic"? I still get
100 MB/s.

cheers,
  Michael
