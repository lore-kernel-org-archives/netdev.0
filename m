From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: [RFC] datalink layer rx side -> move up to network stack
Date: Wed, 15 May 2002 15:36:52 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205151520480.9865-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi list here is a small RFC:

what about moving the datalink layer handling out from the driver
to the network stack. (e.g. netif_receive_skb)

-	if packet is invalid, we're wasting some time (and possible
	space) ... but most datalink implementation today are not
	checking for valid frames anyway
- 	if we've some LLC processing to do, we add some more time
	to respond
-	problems with datalink protocols which need to do SAR
	(segmentation and reassembly) on SMP machines (explaination:
	the network features a queue per CPU, and so after having
	placed a frame (skb) into one of the per CPU queues order
	cannot be guaranteed)
	solutions:
		1) use the IRQ affinity to bind the device to a single
			CPU
		2) do SAR at the driver layer - this ensures order
+	TAPs (like tcpdump) will be able to see EVERYTHING which
	comes in the wire - finally use tcpdump as a tool to dump
	everything the kernel sees :)
+	possibility to establish a clean interface to the datalink
	layers (the dll need some cleanup IMHO)
	+	possibility to reuse datalink layers (today there
		are several implementation of the same protocol
		spread around the kernel tree - drivers/net/* isdn/*)
+	shorter ISRs for the drivers - the datalink stuff is usually
	handled within the driver ISR (by calling e.g. eth_type_trans)
	right before passing the data up to the network subsystem
	(via netif_rx)

	what do you think?

		tm
-- 
in some way i do, and in some way i don't.
