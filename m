From: "Ian Brown" <ianbrn@gmail.com>
Subject: Why MLDv2 Report packet is freed ?
Date: Tue, 15 Apr 2008 16:23:33 +0300
Message-ID: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:44328 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943AbYDONXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 09:23:35 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1993260fgb.17
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 06:23:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a question about the multicast routing support and pim6sd in
this latest tree;

I tried to run pim6sd daemon on a kernel with the latest updates from
the git tree;
and I had also a host with the latest updates from the git tree.
(The  pim6sd is taken from yoshifuji mcast-tools git tree.0

When a host joins a multicast group  a
Multicast Listener Report V2 (MLDV2) is sent. It is of type 143,
which is ICMPV6_MLD2_REPORT. I can see it with a sniffer on the router machine
running pim6sd.

The destination of the MLDv2 report is ff02::16.

Now, I don't understand something here:
I had looked at icmpv6_rcv() in net/ipv6/icmp.c.

I see that when the type of the ICMP packet is ICMPV6_MLD2_REPORT it
is dropped (calling kfree_skb()).

shouldn't it be handled and passed onward so that it will
eventually reach the pim6sd daemon ? or is this
only implemented currently for MLDV1 ?

I want to add that I saw on the machine running pim6sd that
this packet does not reach accept_mld6(). (I added some printing there).

This does not change also with "phyint eth0 mld_version 2" to pim6sd.conf;

Two last notes:
- I had mc_forwarding and forwarding set for IPv6 on the router machine.
- pim6stat shows possible MLD version = 1 on all interfaces (also after
  restarting pim6sd with mld_version 2).

Regards,
IB
