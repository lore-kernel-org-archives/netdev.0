From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Mon, 08 Jul 2013 06:47:49 -0700
Message-ID: <1373291269.4979.102.camel@edumazet-glaptop>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:45196 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab3GHNrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 09:47:52 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so4058412pdi.39
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 06:47:51 -0700 (PDT)
In-Reply-To: <20130708095459.GA29788@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 11:54 +0200, Pavel Machek wrote:
> Hi!
> 
> I've small Intel desktop with RTL8111/8168B ethernet... but the
> performance is extremely bad.
> 
> In 3.10, I only get about 200KB/sec:
> 
> pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
> pavel@duo's password: 
> delme                                               100%   16MB
> 236.0KB/s   01:09    
> 
> In older version, I get 1MB/s, but network fails every 10 minutes or
> so. Card is:
> 
> 03:00.0 Ethernet controller: Realtek Semiconductor Co.,
> Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
> 
> I did install firmware-realtek package as suggested by debian
> installer.
> 
> Dmesg says:
> 
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8010000,
> 00:27:0e:2a:43:71, XID 081000c0 IRQ 17
> r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx
> checksumming: ko]
> 
> Any ideas what is wrong?

Hi Pavel

I guess receiving is OK ?

It looks like TSO packets are not transmitted, so TCP only 'works'
because retransmits use non TSO packets.

Could you report "ethtool -k eth0" ?

try : ethtool -K eth0 tso off
