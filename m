From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv[4|6]: correct dropwatch false positive
 in local_deliver_finish
Date: Fri, 01 Mar 2013 15:57:09 -0500 (EST)
Message-ID: <20130301.155709.1482599990846126981.davem@davemloft.net>
References: <1362159848-8530-1-git-send-email-nhorman@tuxdriver.com>
	<1362160604.15793.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, reich@ulticom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3CAU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 15:57:13 -0500
In-Reply-To: <1362160604.15793.57.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Mar 2013 09:56:44 -0800

> On Fri, 2013-03-01 at 12:44 -0500, Neil Horman wrote:
>> I had a report recently of a user trying to use dropwatch to localise some frame
>> loss, and they were getting false positives.  Turned out they were using a user
>> space SCTP stack that used raw sockets to grab frames.  When we don't have a
>> registered protocol for a given packet, we record it as a drop, even if a raw
>> socket receieves the frame.  We should only record the drop in the event a raw
>> socket doesnt exist to receive the frames
>> 
>> Tested by the reported successfully
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> Reported-by: William Reich <reich@ulticom.com>
>> Tested-by: William Reich <reich@ulticom.com>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: William Reich <reich@ulticom.com>
>> CC: eric.dumazet@gmail.com
>> ---
>>  net/ipv4/ip_input.c  | 6 ++++--
>>  net/ipv6/ip6_input.c | 6 ++++--
>>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> Thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

This seems like a reasonable bug fix so I'm going to apply this to
'net', thanks everyone.
