From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del
 command to reset
Date: Tue, 17 Aug 2010 10:11:15 -0700
Message-ID: <20100817171115.GA4134@mcarlson.broadcom.com>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
 <1281953960.2524.23.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
 <1282050920.2448.47.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
 <1282055659.2448.58.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Thomas Habets" <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4067 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088Ab0HQRLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 13:11:23 -0400
In-Reply-To: <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 17, 2010 at 08:58:26AM -0700, Thomas Habets wrote:
> On Tue, 17 Aug 2010, Eric Dumazet wrote:
> > Try following patch to check tg3 receives correct multicast list (its OK
> > for me, seen on dmesg output)
> >
> > [17162.120238]  add mc_addr(ha->addr=33:33:00:00:00:01)
> > [17162.120270]  add mc_addr(ha->addr=01:00:5e:00:00:01)
> > [17162.120298]  add mc_addr(ha->addr=33:33:ff:87:96:ce)
> > [17162.120326]  add mc_addr(ha->addr=33:33:ff:5c:00:02)
> > [17162.120355] filters=80000001 00000000 00400000 40000000
> 
> Right after boot:
> 
> $ dmesg | egrep 'eth0|^add mc|^filters='
> tg3 0000:03:04.0: eth0: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) 
> MAC address 00:24:81:a3:44:24
> tg3 0000:03:04.0: eth0: attached PHY is 5714 (10/100/1000Base-T Ethernet) 
> (WireSpeed[1])
> tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
> tg3 0000:03:04.0: eth0: dma_rwctrl[76148000] dma_mask[40-bit]
> add mc_addr(ha->addr=33:33:00:00:00:01)
> filters=80000000 00000000 00000000 00000000
> add mc_addr(ha->addr=33:33:00:00:00:01)
> filters=80000000 00000000 00000000 00000000
> add mc_addr(ha->addr=33:33:00:00:00:01)
> filters=80000000 00000000 00000000 00000000
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> filters=80000000 00000000 00000000 40000000
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> filters=80000000 00000000 00000000 40000000
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> filters=80000000 00000000 00000000 40000000
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> filters=80000001 00000000 00000000 40000000
> tg3 0000:03:04.0: eth0: Link is up at 1000 Mbps, full duplex
> tg3 0000:03:04.0: eth0: Flow control is off for TX and off for RX
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> add mc_addr(ha->addr=33:33:ff:a3:44:24)
> filters=80020001 00000000 00000000 40000000
> eth0: no IPv6 routers present
> 
> [ ifconfig eth0 allmulti
>    (ip l and ifconfig say ALLMULTI is on)
> ]
> 
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> add mc_addr(ha->addr=33:33:ff:a3:44:24)
> filters=80020001 00000000 00000000 40000000
> 
> [
>    $ sudo ifconfig eth0 -allmulti
>    Warning: Interface eth0 still in ALLMULTI mode.
>    (ip l and ifconfig say ALLMULTI is now off)
> ]
> 
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> add mc_addr(ha->addr=33:33:ff:a3:44:24)
> filters=80020001 00000000 00000000 40000000
> 
> [ ifconfig eth0 allmulti
>    (same effect)
> ]
> 
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> add mc_addr(ha->addr=33:33:ff:a3:44:24)
> filters=80020001 00000000 00000000 40000000
> 
> [
>    $ sudo ifconfig eth0 -allmulti
>    Warning: Interface eth0 still in ALLMULTI mode.
>    (same effect)
> ]
> 
> add mc_addr(ha->addr=33:33:00:00:00:01)
> add mc_addr(ha->addr=01:00:5e:00:00:01)
> add mc_addr(ha->addr=33:33:ff:5c:00:02)
> add mc_addr(ha->addr=33:33:ff:a3:44:24)
> filters=80020001 00000000 00000000 40000000
> 
> 
> > But if problem remains even with "ifconfig eth0 allmulti" I suspect a
> > NIC firmware problem. (allmulti set to 1 all the 128 bits of filters)

I suspect Eric is right.

Thomas, can you give me the output of 'ethtool -i eth0'?

> If you expected more bits set in "filters" with allmulti than without it, 
> that doesn't seem to be the case.

"allmulti" has the effect of enabling all 128 bits of the multicast hash
filters.  It doesn't explicitly enable them all though.

> Applied your patch to v2.6.35.
> 
> ---------
> typedef struct me_s {
>    char name[]      = { "Thomas Habets" };
>    char email[]     = { "thomas@habets.pp.se" };
>    char kernel[]    = { "Linux" };
>    char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
>    char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
>    char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
> } me_t;
> 

