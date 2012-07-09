From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/4] pch_gbe: fix the checksum fill to the error location
Date: Mon, 9 Jul 2012 21:16:03 +0100
Message-ID: <1341864963.2535.55.camel@bwh-desktop.uk.solarflarecom.com>
References: <40680C535D6FE6498883F1640FACD44D010BFC0F@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64609 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752966Ab2GIUQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 16:16:06 -0400
In-Reply-To: <40680C535D6FE6498883F1640FACD44D010BFC0F@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 06:30 -0700, Andy Cress wrote:
> From: Zhong Hongbo <hongbo.zhong@windriver.com>
> Date: Mon, 9 Apr 2012 10:51:28 +0800
> 
> Due to some unknown hardware limitations the pch_gbe hardware cannot
> calculate checksums when the length of network package is less
> than 64 bytes, where we will surprisingly encounter a problem of
> the destination IP incorrectly changed.
> 
> When forwarding network packages at the network layer the IP packages
> won't be relayed to the upper transport layer and analyzed there,
> consequently, skb->transport_header pointer will be mistakenly remained
> the same as that of skb->network_header, resulting in TCP checksum
> wrongly
> filled into the field of destination IP in IP header.
>
> We can fix this issue by manually calculate the offset of the TCP
> checksum
>  and update it accordingly.
[...]

You should be using skb_checksum_start_offset() instead.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
