From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 09:04:47 -0700
Message-ID: <20100805090447.3f67d990@nehalam>
References: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Usha Srinivasan <usha.srinivasan@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36021 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012Ab0HEQEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 12:04:49 -0400
In-Reply-To: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Aug 2010 09:20:03 -0500
Usha Srinivasan <usha.srinivasan@qlogic.com> wrote:

> Hello,
> I have run into an interesting and frustrating problem which I've not been able to resolve. I am hoping someone can help me.  
> 
> I have a network driver which sets its dev->weight to 100 (like ipoib) and when it processes 100 received packets, following the rules, it decrements dev->quota and *budget and returns 1 without calling netif_rx_complete.  When my driver does that, all processing of incoming packets for all interfaces comes to a halt.  
> 
> How do I know this?  Because, as soon as my driver returns 1 to dev->poll, I lose my putty session and eth0 stops working; eth0 counters show that it stops receiving packets, though it is able to transmit.  My own device stops receiving packets.  I have scoured the code for ipoib and other network devices and I see no difference in what my driver does.  I have tried to lower weight for ipoib & eth0 hoping to reproduce with those device it but no luck.

You maybe looking at old documentation on how NAPI works. 
In NAPI <= 2.6.23, the driver changed  dev->quota and budget
and returned 0 or 1.

For current kernels, the NAPI poll has changed.
Using your example,
  dev->weight = 100
  budget would be 100
 if your network driver process 100 packets, it should return 100
 and call napi_complete().
