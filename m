From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] rhashtable: unconditionally grow when max_shift
 is not specified
Date: Wed, 25 Feb 2015 17:36:38 +0100
Message-ID: <54EDFA16.20308@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net> <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net> <20150225162846.GA13107@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58135 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbbBYQgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:36:47 -0500
In-Reply-To: <20150225162846.GA13107@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 05:28 PM, Thomas Graf wrote:
> On 02/25/15 at 04:31pm, Daniel Borkmann wrote:
>> diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
>> index 58b9953..f9e9d73 100644
>> --- a/lib/test_rhashtable.c
>> +++ b/lib/test_rhashtable.c
>> @@ -202,8 +202,6 @@ static int __init test_rht_init(void)
>>   		.key_len = sizeof(int),
>>   		.hashfn = jhash,
>>   		.nulls_base = (3U << RHT_BASE_SHIFT),
>> -		.grow_decision = rht_grow_above_75,
>> -		.shrink_decision = rht_shrink_below_30,
>>   	};
>>   	int err;
>
> I assume you wanted this chunk in patch 2.

No, it's in this chunk on purpose. ;)

I've tried to explain it here in the commit message:

   Given that the test case verifies shrinks/expands manually, we also
   must remove pointer to the helper functions to explicitly avoid
   parallel resizing on insertions/deletions. test_bucket_stats() and
   test_rht_lookup() could also be wrapped around rhashtable mutex to
   explicitly synchronize a walk from resizing, but I think that defeats
   the actual test case which intended to have explicit test steps,
   i.e. 1) inserts, 2) expands, 3) shrinks, 4) deletions, with object
   verification after each stage.

If we leave it as is, the test case may fail due to a resize run
competing in parallel with the walk (as it's not using Herbert's
API) - I assume the purpose of the test case was to test expands
and shrinks manually in stages and walk/verify the table after
each step.

Cheers,
Daniel
