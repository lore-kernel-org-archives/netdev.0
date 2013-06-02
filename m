From: Felipe Dias <felipediassss@gmail.com>
Subject: ETH_P_ALL and tcp ports
Date: Sun, 2 Jun 2013 12:42:40 -0300
Message-ID: <CAJX4=r3JivtYLFG=Eh0qiTmyufCF414-h4siJCHoL3wAaRVLKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:55541 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3FBPml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 11:42:41 -0400
Received: by mail-ob0-f193.google.com with SMTP id xk17so1667851obc.8
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 08:42:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, someone might try to tell me what I'm doing wrong, please?

I have a simple module and I registered one packet handler, in init function:
---
     pseudo_proto.type = htons(ETH_P_ALL);
     pseudo_proto.dev = NULL;
     pseudo_proto.func = packet_handler;
     dev_add_pack(&pseudo_proto);
---

My packet_handler, is a simple function just to print in dmesg info
about the packet, its check if protocol is TCP or UDP before.

The problem is with TCP headers. I'm trying to get tcp ports with:

ntohs(tcp_hdr(skb)->dest);

But always come strange ports numbers.

My question is: Are the TCP headers filled at this stage ?
Or I have to register another packet_handler with dev_add_pack() after
TCP code have done the heavy work?

Best regards,
Felipe
