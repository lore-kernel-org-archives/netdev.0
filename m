From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: kernel dies if loopback device not intialized
Date: Wed, 17 Jun 2009 21:51:22 -0500
Message-ID: <1245293482.10073.5.camel@merlyn>
References: <20090610203536.4357d309@nehalam>
	 <1245080498.7134.15.camel@Maple>  <20090616215331.2a1bd276@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f198.google.com ([209.85.210.198]:46486 "EHLO
	mail-yx0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbZFRC42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:56:28 -0400
Received: by yxe36 with SMTP id 36so503707yxe.33
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 19:56:30 -0700 (PDT)
In-Reply-To: <20090616215331.2a1bd276@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-06-16 at 21:53 -0700, Stephen Hemminger wrote:
> The packets come from SNMP smux which opens a TCP socket over 127.1
> but the loopback interface is in admin down. 

Hmmm...the stack is doing the ARP because it doesn't have a valid route
for 127.0.0.1.  But I would expect it to be ARPing a default router, and
getting a response (modulo your network state).  What am I missing?

> I suspect the packet
> bouncing from ARP is the TCP SYN packet which does not have a
> mac_header()
> because it is going over the (down) loopback.

Loopback packets have a L2 header--it's just not very interesting.

Even if they never got an L2 header added, skb->mac_header shouldn't be
garbage.

  --  John

