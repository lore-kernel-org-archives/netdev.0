From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/3] rhashtable: require max_shift definition
Date: Tue, 10 Feb 2015 09:30:03 +0100
Message-ID: <54D9C18B.5090208@iogearbox.net>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com> <1423529311-26050-2-git-send-email-johunt@akamai.com> <20150210005801.GA8951@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josh Hunt <johunt@akamai.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150210005801.GA8951@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/2015 01:58 AM, Thomas Graf wrote:
> On 02/09/15 at 07:48pm, Josh Hunt wrote:
>>   	if ((params->key_len && !params->hashfn) ||
>> -	    (!params->key_len && !params->obj_hashfn))
>> +	    (!params->key_len && !params->obj_hashfn) ||
>> +	    (!params->max_shift))
>>   		return -EINVAL;
>
> You can drop the parenthesis around the new max_shift check.

Also, I think the test should be expanded to check if there's
a grow_decision given and only in that case require max_shift
to be non-zero, otherwise we would require users who don't
want to expand their table to give a upper expansion limit.

Thanks,
Daniel
