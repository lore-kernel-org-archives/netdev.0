From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH 1/3] rhashtable: require max_shift definition
Date: Tue, 10 Feb 2015 09:56:03 -0600
Message-ID: <54DA2A13.5010204@akamai.com>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com> <1423529311-26050-2-git-send-email-johunt@akamai.com> <20150210005801.GA8951@casper.infradead.org> <54D9C18B.5090208@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <54D9C18B.5090208@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/2015 02:30 AM, Daniel Borkmann wrote:
> On 02/10/2015 01:58 AM, Thomas Graf wrote:
>> On 02/09/15 at 07:48pm, Josh Hunt wrote:
>>>       if ((params->key_len && !params->hashfn) ||
>>> -        (!params->key_len && !params->obj_hashfn))
>>> +        (!params->key_len && !params->obj_hashfn) ||
>>> +        (!params->max_shift))
>>>           return -EINVAL;
>>
>> You can drop the parenthesis around the new max_shift check.
>
> Also, I think the test should be expanded to check if there's
> a grow_decision given and only in that case require max_shift
> to be non-zero, otherwise we would require users who don't
> want to expand their table to give a upper expansion limit.

This is a good point. I'll make this change.

max_shift restricts the # of buckets, but should there be an optional 
parameter, maxelems, to set a ceiling on the # of elements in a table 
also? If not, I believe users will be able to add an "unlimited" # of 
entries to the existing buckets, whether or not a grow_decision fn is 
defined.

Josh
