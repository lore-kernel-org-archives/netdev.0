From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NetDev! Please help!
Date: Sat, 20 Sep 2008 21:11:01 +0300
Message-ID: <200809202111.01256.denys@visp.net.lb>
References: <48D4F85C.8090709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:48981 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbYITSNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 14:13:05 -0400
In-Reply-To: <48D4F85C.8090709@bigtelecom.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 20 September 2008, Badalian Vyacheslav wrote:
> Hello all.
>
> We buy 10 Intel servers and paste it to shape traffic. After 5-15 hours
> all PC is was freeze!  Kernel not see TCO watchdog at this platform and
> can't reboot it!. Soft Watchdog not reboot pc in this situation.  =(
>
> At screen we see messages like this (when it freeze and i was near
> monitor):
Maybe try nmi_watchdog=1 ?
Also try http://www.nongnu.org/dmidecode/ - to check if it has IPMI.
Mine for example:
....
Handle 0x003F, DMI type 38, 16 bytes
IPMI Device Information
        Interface Type: KCS (Keyboard Control Style)
        Specification Version: 2.0
        I2C Slave Address: 0x10
        NV Storage Device Address: 0
        Base Address: 0x0000000000000CA2 (I/O)

Also important to change it to newer 2.6.26.5 , because for example 2.6.26.4 
have fix: 

http://www.kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.26.4
....

commit 685f605a498b73759cbcbc816089e804710fcc48
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Aug 27 22:35:56 2008 -0700

    pkt_sched: Fix return value corruption in HTB and TBF.
    
    [ Upstream commit 69747650c814a8a79fef412c7416adf823293a3e ]
    
    Based upon a bug report by Josip Rodin.
    
    Packet schedulers should only return NET_XMIT_DROP iff
    the packet really was dropped.  If the packet does reach
    the device after we return NET_XMIT_DROP then TCP can
    crash because it depends upon the enqueue path return
    values being accurate.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
....


P.S. For netdev, i have one more friend - who is complaining that shapers is 
crashing on Intel machines (who uses TSC, he have two different "Core" based 
servers, and both is crashing). With HPET i dont have any problem on high 
performance shapers (except, that it is CPU expensive). It happens on latest 
2.6.26.5 too. Machine getting hard lockup, and nothing than hardware watchdog 
able to recover it. They dont have experience to get actual reason of this 
issue and they dont know english well to report this issue.

