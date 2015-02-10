From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH 1/3] rhashtable: require max_shift definition
Date: Tue, 10 Feb 2015 15:18:16 -0600
Message-ID: <54DA7598.6090201@akamai.com>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com> <1423529311-26050-2-git-send-email-johunt@akamai.com> <20150210005801.GA8951@casper.infradead.org> <54D9C18B.5090208@iogearbox.net> <54DA2A13.5010204@akamai.com> <54DA3A9F.9090608@iogearbox.net> <20150210172241.GB9301@casper.infradead.org> <FB9AAD93-7F9C-440E-8EB2-44D50B8AA22A@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:41203 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696AbbBJVSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 16:18:17 -0500
In-Reply-To: <FB9AAD93-7F9C-440E-8EB2-44D50B8AA22A@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2015 11:44 AM, Patrick McHardy wrote:
> Am 10. Februar 2015 18:22:41 MEZ, schrieb Thomas Graf <tgraf@suug.ch>:
>> On 02/10/15 at 06:06pm, Daniel Borkmann wrote:
>>> Hm, given that min_shift/max_shift are parameters that directly
>>> concern internals of rhashtable i.e. are tightly coupled to expand
>>> and shrink functionality, I'd say that depending on the use case,
>>> a maxelem limit should rather be handled outside of it, if it's
>>> truly an issue/concern.
>>
>> Agreed, Netlink already uses the atomic counter of rhashtable to
>> enforce  upper limit of table entries:
>>
>>         err = -ENOMEM;
>>         if (BITS_PER_LONG > 32 &&
>>             unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
>>                 goto err;
>
> I would tend to agree with Pablo, now we're handling half (shift) internally and half (max) externally, using internal values.

OK. Thanks for all the feedback. I will send a v2 once the other 2 
patches get reviewed.

Thanks
Josh
