From: Simon Chen <simonchennj@gmail.com>
Subject: bizarre tcp rst out of nowhere...
Date: Tue, 8 May 2012 22:04:34 -0400
Message-ID: <CANj2EbebWxd85ddKYuT_2q=ZJRMG+FdD_RwJGNE9jbcs0BuBKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:53221 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab2EICEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 22:04:36 -0400
Received: by wibhj6 with SMTP id hj6so1337984wib.1
        for <netdev@vger.kernel.org>; Tue, 08 May 2012 19:04:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am running a ubuntu 11.04 server, with kernel flavor 2.6.38-13-server.

The server is running nova-network, the openstack network controller.
Essentially, it is doing a static NATting function. When a packet
comes from a VM, it SNAT the VM's private src IP to a public floating
IP and send the packet out. When a packet is sent to the floating IP,
it DNAT the packet to the VM's private IP in reverse.

So, the server in question should be a strictly pass-through device,
while doing address translation. It doesn't have any additional
filtering rules.

I have a remote client trying to "curl https://floater_ip". The
bizarre thing is that this sometimes works, sometimes doesn't. When it
works, the packets go through my NAT server as normal. When it doesn't
work, it seems that my NAT server decides to send back a tcp-rst
immediately after the tcp-syn is received - it is supposed to pass it
on, not process it locally...

Any idea why this happens?

I've been watching the server closely, the floater IP is always on the
public nic, the iptables rules are always there, the interface is
always up, the backend VM is always reachable...

-Simon
