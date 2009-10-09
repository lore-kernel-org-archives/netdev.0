From: Gabor Gombas <gombasg@sztaki.hu>
Subject: PACKET_TX_RING: packet size is too long
Date: Fri, 9 Oct 2009 11:07:11 +0200
Message-ID: <20091009090711.GG23133@boogie.lpds.sztaki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johann.baudy@gnu-log.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from boogie.lpds.sztaki.hu ([193.224.70.237]:46772 "EHLO
	boogie.lpds.sztaki.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbZJIJP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 05:15:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have added PACKET_TX_RING support to ggaoed
(http://code.google.com/p/ggaoed) and it have worked nice when I have
tested it with a virtual ethernet pair (veth). However when testing it
on real hardware, I get:

Oct  8 17:30:52 storage2 kernel: [ 1083.714204] packet size is too long (8740 > 8472)

Kernel is 2.6.31 from Debian experimental. The socket is SOCK_RAW, the
MTU is 9000, I'm using TPACKET_V2 format, and the ring have been created
with the following parameters:

block_nr = 256, block_size = 65536, frame_nr = 1792, frame_size = 9056

Documentation/networking/packet_mmap.txt says that a frame for
PACKET_TX_RING consists of a struct tpacket[2]_hdr followed by the data
to send, so IMHO a frame size of 9056 should be enough to send 8740
bytes of data. However, net/packet/af_packet.c has in tpacket_snd():

	size_max = po->tx_ring.frame_size
		- sizeof(struct skb_shared_info)
		- po->tp_hdrlen
		- LL_ALLOCATED_SPACE(dev)
		- sizeof(struct sockaddr_ll);

which is much more than just the struct tpacket[2]_hdr. So which is
right? The code or the documentation? What is the official formula
to compute the required frame length for a SOCK_RAW socket, given the
MTU?

Gabor

-- 
     ---------------------------------------------------------
     MTA SZTAKI Computer and Automation Research Institute
                Hungarian Academy of Sciences
     ---------------------------------------------------------
