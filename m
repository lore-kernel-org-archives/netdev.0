From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: Re: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Tue, 21 Apr 2015 22:57:54 +0200
Message-ID: <5536B9D2.7030200@gmail.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>	 <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com> <1429492384.27863.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429492384.27863.13.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe, 

On 20.04.2015 03:13, Joe Perches wrote:
> On Mon, 2015-04-20 at 00:16 +0200, Mateusz Kulikowski wrote:
>> Suggest using eth_zero_addr() or eth_broadcast_addr() instead of memset().
> 
> Hi again Mateusz
> 
>> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
>> @@ -5042,6 +5042,22 @@ sub process {
>>  			     "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . $herecurr)
>>  		}
>>  
>> +# check for memset(foo, 0x0, ETH_ALEN) that could be eth_zero_addr
>> +# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
>> +		if ($^V && $^V ge 5.10.0 &&
>> +		    $line =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
> 
> Because you are working with $line and not $stat,
> the last /s isn't useful here.
> 
> $line is always a single line.

Perhaps it would be smarter to use (for both patches) $stat instead.
This applies also to existing checks (like PREFER_ETHER_ADDR_COPY) 
so we can catch calls formatted like

memset(very.long.structure->something.something_different42,
       0xFF, ETH_ALEN);


Regards,
Mateusz
