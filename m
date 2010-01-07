From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Thu, 7 Jan 2010 15:23:05 -0800
Message-ID: <201001071523.05430.dmitry.torokhov@gmail.com>
References: <201001071156.31892.dmitry.torokhov@gmail.com> <20100107225213.GA4310@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:42910 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab0AGXXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 18:23:20 -0500
Received: by pzk1 with SMTP id 1so3306311pzk.33
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 15:23:19 -0800 (PST)
In-Reply-To: <20100107225213.GA4310@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 January 2010 02:52:13 pm Matt Carlson wrote:
> On Thu, Jan 07, 2010 at 11:56:31AM -0800, Dmitry Torokhov wrote:
> > Hi,
> >
> > Ever since I moved post 2.6.32 tg3 seems to be very sick in my Latitude
> > D630, it discards most of the packages for some reason:
> >
> > [root@dtor-d630 ~]# ethtool -S eth0 | grep rx_
> >      rx_octets: 35886
> >      rx_fragments: 0
> >      rx_ucast_packets: 9
> >      rx_mcast_packets: 93
> >      rx_bcast_packets: 237
> >      rx_fcs_errors: 0
> >      rx_align_errors: 0
> >      rx_xon_pause_rcvd: 0
> >      rx_xoff_pause_rcvd: 0
> >      rx_mac_ctrl_rcvd: 0
> >      rx_xoff_entered: 0
> >      rx_frame_too_long_errors: 0
> >      rx_jabbers: 0
> >      rx_undersize_packets: 0
> >      rx_in_length_errors: 0
> >      rx_out_length_errors: 0
> >      rx_64_or_less_octet_packets: 0
> >      rx_65_to_127_octet_packets: 0
> >      rx_128_to_255_octet_packets: 0
> >      rx_256_to_511_octet_packets: 0
> >      rx_512_to_1023_octet_packets: 0
> >      rx_1024_to_1522_octet_packets: 0
> >      rx_1523_to_2047_octet_packets: 0
> >      rx_2048_to_4095_octet_packets: 0
> >      rx_4096_to_8191_octet_packets: 0
> >      rx_8192_to_9022_octet_packets: 0
> >      rx_discards: 304
> >      rx_errors: 0
> >      rx_threshold_hit: 0
> >
> > The above on last night pull from Linux (so 2.6.33+).
> >
> > Everything works fine if I use wireless or another wired card (Realtek in
> > cardbus slot):
> >
> > [root@dtor-d630 ~]# lspci | grep -ri net
> > 04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> > RTL-8139/8139C/8139C+ (rev 10)
> > 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M
> > Gigabit Ethernet PCI Express (rev 02)
> > 0c:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG
> > [Golan] Network Connection (rev 02)
> >
> > [root@dtor-d630 ~]# ethtool eth0
> > Settings for eth0:
> >         Supported ports: [ TP ]
> >         Supported link modes:   10baseT/Half 10baseT/Full
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Half 1000baseT/Full
> >         Supports auto-negotiation: Yes
> >         Advertised link modes:  10baseT/Half 10baseT/Full
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Half 1000baseT/Full
> >         Advertised auto-negotiation: Yes
> >         Speed: 1000Mb/s
> >         Duplex: Full
> >         Port: Twisted Pair
> >         PHYAD: 1
> >         Transceiver: internal
> >         Auto-negotiation: on
> >         Supports Wake-on: g
> >         Wake-on: g
> >         Current message level: 0x000000ff (255)
> >         Link detected: yes
> >
> > Any ideas? Thanks!
> 
> O.K.  I had the same problem with the 5755M that another reported had
> with a 5787M.  Once I applied the following patch, everything worked.
> Can you see if the patch works for you too?

Wooo-hooo! I don't need cardbus card sticking off the side of my laptop 
anymore. Thank you very much for the quick fix.

Tested-by: Dmitry Torokhov <dtor@mail.ru>

-- 
Dmitry
