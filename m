From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 10:43:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Greg Banks" <gnb@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> On a related note, is there a good reason why the tg3 driver 
> uses the on-chip SRAM send ring by default instead of the 
> host send ring? This seems like it would dramatically 
> increase the PIO load on the chipset for some of the 
> workloads I'm interested in.
> 

I can only speak for the Broadcom bcm5700 driver. We used to use NIC
send BDs by default before zero copy transmit and TSO were implemented
in the kernel. Using only one BD per packet at that time, we found that
performance on some machines were sometimes slightly better. Especially
with logic to save some PIO when some of the fields in the BD have not
changed. The driver has now been changed to use host send BDs to perform
better with zero copy and especially TSO where you may need many BDs per
packet. I would recommend tg3 to make the switch also.

Michael
