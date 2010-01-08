From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Thu, 7 Jan 2010 16:14:54 -0800
Message-ID: <20100108001453.GA2436@core.coreip.homeip.net>
References: <201001071156.31892.dmitry.torokhov@gmail.com>
 <20100107204835.GB5788@xw6200.broadcom.net>
 <4B465F2C.1080208@gmail.com>
 <201001071445.44550.dmitry.torokhov@gmail.com>
 <20100107235309.GA4515@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:61546 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab0AHAPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 19:15:13 -0500
Received: by pwj9 with SMTP id 9so12318193pwj.21
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 16:15:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100107235309.GA4515@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 03:53:09PM -0800, Matt Carlson wrote:
> On Thu, Jan 07, 2010 at 02:45:43PM -0800, Dmitry Torokhov wrote:
> > On Thursday 07 January 2010 02:24:44 pm Eric Dumazet wrote:
> > > Le 07/01/2010 21:48, Matt Carlson a ?crit :
> > > > Nothing jumps to mind.  Let me see if I can repro this here.
> > > >
> > > > On Thu, Jan 07, 2010 at 11:56:31AM -0800, Dmitry Torokhov wrote:
> > > >> Hi,
> > > >>
> > > >> Ever since I moved post 2.6.32 tg3 seems to be very sick in my Latitude
> > > >> D630, it discards most of the packages for some reason:
> > > >>
> > > >> [root@dtor-d630 ~]# ethtool -S eth0 | grep rx_
> > > >>      rx_octets: 35886
> > > >>      rx_fragments: 0
> > > >>      rx_ucast_packets: 9
> > > >>      rx_mcast_packets: 93
> > > >>      rx_bcast_packets: 237
> > > >>      rx_fcs_errors: 0
> > > >>      rx_align_errors: 0
> > > >>      rx_xon_pause_rcvd: 0
> > > >>      rx_xoff_pause_rcvd: 0
> > > >>      rx_mac_ctrl_rcvd: 0
> > > >>      rx_xoff_entered: 0
> > > >>      rx_frame_too_long_errors: 0
> > > >>      rx_jabbers: 0
> > > >>      rx_undersize_packets: 0
> > > >>      rx_in_length_errors: 0
> > > >>      rx_out_length_errors: 0
> > > >>      rx_64_or_less_octet_packets: 0
> > > >>      rx_65_to_127_octet_packets: 0
> > > >>      rx_128_to_255_octet_packets: 0
> > > >>      rx_256_to_511_octet_packets: 0
> > > >>      rx_512_to_1023_octet_packets: 0
> > > >>      rx_1024_to_1522_octet_packets: 0
> > > >>      rx_1523_to_2047_octet_packets: 0
> > > >>      rx_2048_to_4095_octet_packets: 0
> > > >>      rx_4096_to_8191_octet_packets: 0
> > > >>      rx_8192_to_9022_octet_packets: 0
> > > >>      rx_discards: 304
> > > >>      rx_errors: 0
> > > >>      rx_threshold_hit: 0
> > > >>
> > > >> The above on last night pull from Linux (so 2.6.33+).
> > > >>
> > > >> Everything works fine if I use wireless or another wired card (Realtek
> > > >> in cardbus slot):
> > > >>
> > > >> [root@dtor-d630 ~]# lspci | grep -ri net
> > > >> 04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> > > >> RTL-8139/8139C/8139C+ (rev 10)
> > > >> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M
> > > >> Gigabit Ethernet PCI Express (rev 02)
> > > >> 0c:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG
> > > >> [Golan] Network Connection (rev 02)
> > > >>
> > > >> [root@dtor-d630 ~]# ethtool eth0
> > > >> Settings for eth0:
> > > >>         Supported ports: [ TP ]
> > > >>         Supported link modes:   10baseT/Half 10baseT/Full
> > > >>                                 100baseT/Half 100baseT/Full
> > > >>                                 1000baseT/Half 1000baseT/Full
> > > >>         Supports auto-negotiation: Yes
> > > >>         Advertised link modes:  10baseT/Half 10baseT/Full
> > > >>                                 100baseT/Half 100baseT/Full
> > > >>                                 1000baseT/Half 1000baseT/Full
> > > >>         Advertised auto-negotiation: Yes
> > > >>         Speed: 1000Mb/s
> > > >>         Duplex: Full
> > > >>         Port: Twisted Pair
> > > >>         PHYAD: 1
> > > >>         Transceiver: internal
> > > >>         Auto-negotiation: on
> > > >>         Supports Wake-on: g
> > > >>         Wake-on: g
> > > >>         Current message level: 0x000000ff (255)
> > > >>         Link detected: yes
> > > >>
> > > >> Any ideas? Thanks!
> > > 
> > > My laptop is a D630, and running 2.6.33-rc3 with no special problems on tg3
> > >
> > 
> > This is wierd... It all works well with Fedora 12 kernel and .32 so hardware 
> > is fine here. I think it also worked when I plugged it into my home router 
> > (will try it again tonight). But in the office it just does not want to work. 
> > It's like it just does not like the addresses that we use here...
> 
> Is the problem related to link speed?  I see that Eric was running at
> 100Mbps.  Your ethtool output above shows that you are running at 1Gbps.
> 

Indeed I have 100Mbps at home and 1Gb in the office.. I amy try playing
with it some more if you want but that patch you sent seems to have
fixed the issue for me...

Except that sice I started using tg3 in couple of hours the box locked
up completely once and panicked twice; of course it happened in X so no
traces whatsoever. Maybe a coincidence though, I am running with nvidia
driver...

-- 
Dmitry
