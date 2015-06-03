From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 03/11] netfilter: don't use module_init/exit in core IPV4
 code
Date: Wed, 3 Jun 2015 12:18:27 -0400
Message-ID: <556F28D3.4060203@windriver.com>
References: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com> <1433120052-18281-4-git-send-email-paul.gortmaker@windriver.com> <20150603160429.GA3565@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38654 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611AbbFCQTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 12:19:11 -0400
In-Reply-To: <20150603160429.GA3565@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-03 12:04 PM, Pablo Neira Ayuso wrote:
> On Sun, May 31, 2015 at 08:54:04PM -0400, Paul Gortmaker wrote:
>> The file net/ipv4/netfilter.o is created based on whether
>> CONFIG_NETFILTER is set.  However that is defined as a bool, and
>> hence this file with the core netfilter hooks will never be
>> modular.  So using module_init as an alias for __initcall can be
>> somewhat misleading.
>>
>> Fix this up now, so that we can relocate module_init from
>> init.h into module.h in the future.  If we don't do this, we'd
>> have to add module.h to obviously non-modular code, and that
>> would be a worse thing.  Also add an inclusion of init.h, as
>> that was previously implicit here in the netfilter.c file.
>>
>> Note that direct use of __initcall is discouraged, vs. one
>> of the priority categorized subgroups.  As __initcall gets
>> mapped onto device_initcall, our use of subsys_initcall (which
>> seems to make sense for netfilter code) will thus change this
>> registration from level 6-device to level 4-subsys (i.e. slightly
>> earlier).  However no observable impact of that small difference
>> has been observed during testing, or is expected. (i.e. the
>> location of the netfilter messages in dmesg remains unchanged
>> with respect to all the other surrounding messages.)
>>
>> As for the module_exit, rather than replace it with __exitcall,
>> we simply remove it, since it appears only UML does anything
>> with those, and even for UML, there is no relevant cleanup
>> to be done here.
>>
>> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: netfilter-devel@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Or I can integrate this into the nf-next tree if you prefer it.

I need to keep it in my series to avoid introducing compile
fails into the bisect history, so I'll just add your Ack.

Thanks,
Paul.
--

> 
> Thanks.
> 
