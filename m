From: "Marjan Schiller" <lxdmail@gmx.de>
Subject: dev_queue_xmit and sockets
Date: Tue, 18 Jan 2011 10:04:40 +0100
Message-ID: <20110118090440.266580@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:43528 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752207Ab1ARJEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 04:04:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I am currently developing a netfilter module which passes incoming and outgoing ethernet packages from one interface to an another interface ( a tun device ). This works very well, the tcpdump shows correct packages on the destination device and PING and ARP works good.

But i get into trouble if i want to create a socket connection with these packages. It seams to me that the packages are only "useable" within the kernel space and not the user space. Did i miss something there? Do i have to prepare the SKB for user mode or something like that?

I can establish a connection between the client socket and the server socket, but the server socket does not read any data ( But the packet with the data has reached the interface ).

Here is an example how i pass the packaged to the tun device:

static unsigned int send_ethernet_package( struct sk_buff * in_skb, void * data, int len, struct net_device * dev )
{
  struct sk_buff *skb;

  skb = alloc_skb( len , GFP_ATOMIC);
  skb_put( skb, len );
  skb->pkt_type = PACKET_HOST;
  skb->dev = dev;
  memcpy(skb->head, data , len );
  dev_queue_xmit( skb );

  return 0;
}

The data parameter is a well formed ethernet package.

Someone how has a guess whats wrong with this?

Thanks for help
    
    Marjan

-- 
Neu: GMX De-Mail - Einfach wie E-Mail, sicher wie ein Brief!  
Jetzt De-Mail-Adresse reservieren: http://portal.gmx.net/de/go/demail
