From: Andy Lutomirski <luto@amacapital.net>
Subject: Accelerated RFS steering the same flow repeatedly on sfc?
Date: Thu, 20 Mar 2014 12:44:15 -0700
Message-ID: <CALCETrX2jmweMXzTvnfMdPkdMkLSr9JujtwO0w8ju=7r+mPhPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>,
	Paul Emberson <pemberson@solarflare.com>,
	Tom Herbert <therbert@google.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:47506 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757263AbaCTTog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 15:44:36 -0400
Received: by mail-vc0-f180.google.com with SMTP id lf12so1564040vcb.11
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 12:44:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a snipped from my kernel log:

[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
159.95.26.109:23042:208.92.147.76:44811 to queue 28 [flow 21 filter
5781] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 130 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
199.29.245.125:11097:10.253.8.22:47709 to queue 28 [flow 477 filter
1497] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
199.29.245.125:11097:10.253.8.22:47709 to queue 30 [flow 272 filter
1497] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
199.29.245.125:11097:10.253.8.22:47709 to queue 30 [flow 272 filter
1497] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 400 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1
[info] sfc 0000:05:00.1 p3p2: steering TCP
169.33.100.144:15986:208.92.147.76:60517 to queue 28 [flow 399 filter
3187] SUBSYSTEM=pci DEVICE=+pci:0000:05:00.1

Sorry about the formatting.  This snippet is less than one second long.

It seems rather odd:

1. The same flow is being steered over and over.  This means that
set_rps_cpu is being called repeatedly, I think.

2. The same flow doesn't have the same flow_id (i.e. rxhash) every time.

The rxhash setting on my interface doesn't seem to matter.

This is Linux 3.13 running the latest OpenOnload driver.  I can try
the stock driver if needed next week.

The data is coming in on a vlan, in case that matters.

The OpenOnload driver is missing this fix:

commit c7cb38af79c1e71a72d398f39296f1e27779b778
Author: Tom Herbert <therbert@google.com>
Date:   Tue Dec 17 23:31:50 2013 -0800

    net: sfc calls skb_set_hash


-- 
Andy Lutomirski
AMA Capital Management, LLC
