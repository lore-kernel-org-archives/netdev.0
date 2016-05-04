From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] igmp: fix byte order in /proc/net/igmp output
Date: Wed, 04 May 2016 12:48:01 -0400 (EDT)
Message-ID: <20160504.124801.841409580551186850.davem@davemloft.net>
References: <1462363884-34968-1-git-send-email-Eugene.Crosser@ru.ibm.com>
	<1462367616.5535.340.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eugene.Crosser@ru.ibm.com, crosser@average.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbcEDQsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 12:48:02 -0400
In-Reply-To: <1462367616.5535.340.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 May 2016 06:13:36 -0700

> On Wed, 2016-05-04 at 14:11 +0200, Eugene Crosser wrote:
>> /proc/net/igmp is a readonly attribute that shows multicast groups
>> to which different network interfaces are subscribed. Among other
>> things, it displays `multiaddr` which is a 32 bit network-byte-order
>> field, in hexadecimal format. Prior to this patch, the field was
>> displayed as an integer, resulting in reverse byte order on little
>> endian architectures. This patch converts it with ntohl() for display
>> the same way as this is done for the /proc/net/mcfilter attribute.
>> 
>> The patch changes (corrects) user-visible behaviour.
>> 
>> Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
>> ---
>>  net/ipv4/igmp.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
>> index b3086cf..f9d2139 100644
>> --- a/net/ipv4/igmp.c
>> +++ b/net/ipv4/igmp.c
>> @@ -2722,7 +2722,7 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
>>  		delta = im->timer.expires - jiffies;
>>  		seq_printf(seq,
>>  			   "\t\t\t\t%08X %5d %d:%08lX\t\t%d\n",
>> -			   im->multiaddr, im->users,
>> +			   ntohl(im->multiaddr), im->users,
>>  			   im->tm_running,
>>  			   im->tm_running ? jiffies_delta_to_clock_t(delta) : 0,
>>  			   im->reporter);
> 
> 
> I do not believe we can change this. This is unfortunately too late.
> 
> /proc/net/tcp has the same 'issue' or if you prefer, well known
> behavior.
> 
> Such change would break basically all /proc/net/igmp users.

Agreed.
