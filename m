From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Tue, 20 Mar 2007 10:27:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703201026300.25136@netcore.fi>
References: <Pine.LNX.4.64.0703191706530.3331@netcore.fi> <45FEAA3E.20601@trash.net>
 <45FEABE1.9050003@trash.net> <20070319.121844.112623702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54609 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbXCTI17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 04:27:59 -0400
In-Reply-To: <20070319.121844.112623702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Mar 2007, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 19 Mar 2007 16:27:29 +0100
>
>> Mhh actually this looks intentional:
>>
>> icmpv6_send and some other output functions do:
>> 	int hlimit;
>> ...
>>         if (hlimit < 0)
>>                 hlimit = dst_metric(dst, RTAX_HOPLIMIT);
>>         if (hlimit < 0)
>>                 hlimit = ipv6_get_hoplimit(dst->dev);
>
> Yep, negative value has a specific meaning.

Which seems to indicate that the kernel-internal implementation has a 
need to store a negative TTL.  Reporting it to the userspace as a 
negative doesn't seem right though?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
