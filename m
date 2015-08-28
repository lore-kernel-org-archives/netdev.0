From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add ethernet header for pass through
 VRF device
Date: Fri, 28 Aug 2015 13:30:31 -0700 (PDT)
Message-ID: <20150828.133031.2062909197129911984.davem@davemloft.net>
References: <1440695450-30545-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbbH1Uab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:30:31 -0400
In-Reply-To: <1440695450-30545-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 10:10:50 -0700

> The change to use a custom dst broke tcpdump captures on the VRF device:
> 
> $ tcpdump -n -i vrf10
> ...
> 05:32:29.009362 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 21989, seq 1, length 64
> 05:32:29.009855 00:00:40:01:8d:36 > 45:00:00:54:d6:6f, ethertype Unknown (0x0a02), length 84:
> 	0x0000:  0102 0a02 01fe 0000 9181 55e5 0001 bd11  ..........U.....
> 	0x0010:  da55 0000 0000 bb5d 0700 0000 0000 1011  .U.....]........
> 	0x0020:  1213 1415 1617 1819 1a1b 1c1d 1e1f 2021  ...............!
> 	0x0030:  2223 2425 2627 2829 2a2b 2c2d 2e2f 3031  "#$%&'()*+,-./01
> 	0x0040:  3233 3435 3637                           234567
> 
> Local packets going through the VRF device are missing an ethernet header.
> Fix by adding one and then stripping it off before pushing back to the IP
> stack. With this patch you get the expected dumps:
> 
> ...
> 05:36:15.713944 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 23795, seq 1, length 64
> 05:36:15.714160 IP 10.2.1.2 > 10.2.1.254: ICMP echo reply, id 23795, seq 1, length 64
> ...
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
