From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Mon, 19 Feb 2007 17:18:45 -0500
Message-ID: <20070219221845.GI7585@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca> <20070219201136.GH7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:56768 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932719AbXBSWSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 17:18:46 -0500
Content-Disposition: inline
In-Reply-To: <20070219201136.GH7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 03:11:36PM -0500, Lennart Sorensen wrote:
> I have been poking at things with firescope to see if the MAC is
> actually writing to system memory or not.
> 
> The entry that it gets stuch on is _always_ entry 0 in the rx_ring.
> There does not appear to be any exceptions to this.  
> 
> Here is my firescope (slightly modified for this purpose) dump of the
> rx_ring of eth1:
> 
> Descriptor:Address: /--base---\ /buf\ /sta\ /-message-\ /reserved-\
>           :       : |         | |len| |tus| | length  | |         |
> RXdesc[00]:6694000: 12 18 5f 05 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[01]:6694010: 12 78 15 05 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[02]:6694020: 12 a0 52 06 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[03]:6694030: 12 f8 c2 04 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[04]:6694040: 12 70 15 05 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[05]:6694050: 12 e8 37 05 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[06]:6694060: 12 e0 37 05 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[07]:6694070: 12 e8 d5 04 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[08]:6694080: 12 e0 d5 04 fa f9 40 03 ee 05 00 00 00 00 00 00
> RXdesc[09]:6694090: 12 d8 d1 05 fa f9 40 03 46 00 00 00 00 00 00 00
> RXdesc[10]:66940a0: 12 d0 d1 05 fa f9 40 03 4e 00 00 00 00 00 00 00
> RXdesc[11]:66940b0: 12 d8 02 05 fa f9 10 03 40 00 00 00 00 00 00 00
> RXdesc[12]:66940c0: 12 d0 02 05 fa f9 40 03 46 00 00 00 00 00 00 00
> RXdesc[13]:66940d0: 12 38 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[14]:66940e0: 12 30 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[15]:66940f0: 12 78 2c 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[16]:6694100: 12 a0 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[17]:6694110: 12 b0 04 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[18]:6694120: 12 b8 04 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[19]:6694130: 12 70 2c 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[20]:6694140: 12 f8 56 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[21]:6694150: 12 c8 29 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[22]:6694160: 12 20 03 05 fa f9 00 80 ee 05 00 00 00 00 00 00
> RXdesc[23]:6694170: 12 60 4c 05 fa f9 00 80 87 05 00 00 00 00 00 00
> RXdesc[24]:6694180: 12 98 53 05 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[25]:6694190: 12 b0 cc 04 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[26]:66941a0: 12 a8 3f 05 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[27]:66941b0: 12 58 e8 04 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[28]:66941c0: 12 b0 4d 06 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[29]:66941d0: 12 38 ef 04 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[30]:66941e0: 12 98 1f 05 fa f9 00 80 40 00 00 00 00 00 00 00
> RXdesc[31]:66941f0: 12 28 f1 04 fa f9 00 80 40 00 00 00 00 00 00 00
> 
> I only ever see entry 0 as status 0080 (0x8000 which is owned by mac),
> and this is while the driver is checking entry 0 every time it tries to
> check for any waiting packets.
> 
> Running tcpdump while pinging gives the interesting result that some
> packets are ariving out of order making it seem like the driver is
> processing the packets out of order.  Perhaps the driver is wrong to be
> looking at entry 0, and should be looking at entry 1 and is hence stuck
> until the whole receive ring has been filled again?
> 
> 15:06:04.112812 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 1
> 15:06:05.119799 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 2
> 15:06:05.120159 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 2
> 15:06:05.127045 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 1
> 15:06:06.119862 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 3
> 15:06:07.119921 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 4
> 15:06:08.119994 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 5
> 15:06:08.426400 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 3
> 15:06:08.427915 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 4
> 15:06:08.429033 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 5
> 15:06:09.120053 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 6
> 15:06:10.120109 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 7
> 15:06:10.705332 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 6
> 15:06:10.707258 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 7
> 15:06:11.120175 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 8
> 15:06:12.120233 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 9
> 15:06:13.120297 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 10
> 15:06:14.120359 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 11
> 15:06:14.120737 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 11
> 15:06:14.127064 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 8
> 15:06:14.127700 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 9
> 15:06:14.128268 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 10
> 15:06:15.120426 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 12
> 15:06:16.120484 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 13
> 15:06:16.120840 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 13
> 15:06:16.129476 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 12
> 15:06:17.120551 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 14
> 15:06:17.615429 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 14
> 15:06:18.120612 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 15
> 15:06:19.120672 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 16
> 15:06:19.748981 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 15
> 15:06:19.749976 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 16
> 15:06:20.120738 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 17
> 15:06:21.120799 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 18
> 15:06:22.120859 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 19
> 15:06:23.120926 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 20
> 15:06:24.120985 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 21
> 15:06:24.881809 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 17
> 15:06:24.882287 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 18
> 15:06:24.882578 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 19
> 15:06:24.883347 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 20
> 15:06:24.884158 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 21
> 15:06:25.129659 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 22
> 
> Does anyone see any reason why the driver would get into such a state
> after a pile of traffic in a row?  So far I have only seen it when NAPI
> is enabled, so I have to assume so far that it makes a difference to it.

With more beating of the driver, I have managed to see it fail in places
other than descriptor 0.  It is as if the MAC doesn't transfer the
descriptor to the system memory, although I am not yet sure if there is
packet loss involved involving retransmision or not.

I tried making this change as a test:

  static int pcnet32_rx(struct net_device *dev, int quota)
  {
          struct pcnet32_private *lp = dev->priv;
          int entry = lp->cur_rx & lp->rx_mod_mask;
+         int nextentry = (lp->cur_rx+1) & lp->rx_mod_mask;
          struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
+         struct pcnet32_rx_head *nextrxp = &lp->rx_ring[nextentry];
          int npackets = 0;

+         /* Check for confused MAC and resync if necesary */
+         if ((short)le16_to_cpu(rxp->status) < 0 && (short)le16_to_cpu(nextrxp->status) >= 0) {
+                 entry = (++lp->cur_rx) & lp->rx_mod_mask;
+                 rxp = &lp->rx_ring[entry];
+                 printk("%s: rx_ring bugfix on entry %d\n",dev->name,entry);
+         }

          /* If we own the next entry, it's a new packet. Send it up. */
          while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
                  pcnet32_rx_entry(dev, lp, rxp, entry);
                  npackets += 1;
                  /*
                   * The docs say that the buffer length isn't touched, but Andrew
                   * Boyd of QNX reports that some revs of the 79C965 clear it.
                   */
                  rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
                  wmb();  /* Make sure owner changes after others are visible */
                  rxp->status = le16_to_cpu(0x8000);
                  entry = (++lp->cur_rx) & lp->rx_mod_mask;
                  rxp = &lp->rx_ring[entry];
          }

          return npackets;
  }

Now this really can't be a solution.  It still occationally gets "stuck"
for a short time, but with this change it manages to recover again but
it does seem to be hitting by printk once in a while.  I am starting to
wonder of the PCI transfers are failing once in a while.  I still can't
figure out what NAPI is doing different unless some of the pcnet32_rx
code should be run with interrupts disabled and isn't in NAPI mode.

eth1: rx_ring bugfix on entry 28
eth1: rx_ring bugfix on entry 15
eth1: rx_ring bugfix on entry 31
eth1: rx_ring bugfix on entry 2
eth1: rx_ring bugfix on entry 23
eth1: rx_ring bugfix on entry 25
eth1: rx_ring bugfix on entry 2
eth1: rx_ring bugfix on entry 21
eth1: rx_ring bugfix on entry 24
eth1: rx_ring bugfix on entry 27
eth1: rx_ring bugfix on entry 28
eth1: rx_ring bugfix on entry 23
eth1: rx_ring bugfix on entry 11
eth1: rx_ring bugfix on entry 28
eth1: rx_ring bugfix on entry 27
eth1: rx_ring bugfix on entry 24
eth1: rx_ring bugfix on entry 28
eth1: rx_ring bugfix on entry 17

--
Len Sorensen
