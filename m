From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Sat, 13 Sep 2003 13:52:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16227.1284.893748.365713@robur.slu.se>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	<3F60CA6D.9090503@pobox.com>
	<3F60D0F3.8080006@candelatech.com>
	<20030911131219.0ab8dfdd.davem@redhat.com>
	<3F60DDCC.5020906@candelatech.com>
	<20030911140746.4f0384a1.davem@redhat.com>
	<3F60E947.4090005@candelatech.com>
	<20030911142906.74d9dfe5.davem@redhat.com>
	<3F60F3F7.6090203@candelatech.com>
	<20030911160252.6cd6c07d.davem@redhat.com>
	<3F6103BB.5030706@candelatech.com>
	<1063330463.1028.8.camel@jzny.localdomain>
	<20030912204947.5267e3aa.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, greearb@candelatech.com, jgarzik@pobox.com,
   scott.feldman@intel.com, netdev@oss.sgi.com, ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030912204947.5267e3aa.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 > On 11 Sep 2003 21:34:23 -0400
 > jamal <hadi@cyberus.ca> wrote:
 > 
 > > dont increase the tx descriptor ring size - that would truly wasting
 > > memory; 256 is pretty adequate.
 > > * increase instead the txquelen (as suggested by Davem); user space
 > > tools like ip or ifconfig could do it. The standard size has been around
 > > 100 for 100Mbps; i suppose it is fair to say that Gige can move data out
 > > at 10x that; so set it to 1000. Maybe you can do this from the driver
 > > based on what negotiated speed is detected?
 > 
 > I spoke with Alexey once about this, actually tx_queue_len can
 > be arbitrarily large but it should be reasonable nonetheless.
 > 
 > Our preliminary conclusions were that values of 1000 for 100Mbit and
 > faster were probably appropriate.  Maybe something larger for 1Gbit,
 > who knows.
 > 
 > We also determined that the only connection between TX descriptor
 > ring size and dev->tx_queue_len was that the latter should be large
 > enough to handle, at a minimum, the amount of pending TX descriptor
 > ACKs that can be pending considering mitigation et al.
 > 
 > So if TX irq mitigation can defer up to N TX descriptor completions
 > then dev->tx_queue_len must be at least that large.
 > 
 > Back to the main topic, maybe we should set dev->tx_queue_len to
 > 1000 by default for all ethernet devices.

 Hello!

 Yes sounds like adequate setting for GIGE. This is what use for production
 and lab but rather than increasing dev->tx_queue_len to 1000 we replace the 
 pfifo_fast with the pfifo qdisc w. setting a qlen of 1000.

 And with we have tx_descriptor_ring_size 256 which is tuned to the NIC's
 "TX service interval" with respect to interrupt mitigation etc. This seems 
 good enough even for small packets.

 For routers this setting is even more crucial as we need to serialize 
 several flows and we know the flows are bursty.


 Cheers.
						--ro
