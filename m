From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 19:24:24 +0200
Message-ID: <560977C8.4090909@redhat.com>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>	 <20150928135127.GB5248@hmsreliant.think-freely.org>	 <063D6719AE5E284EB5DD2968C1650D6D1CBA41B0@AcuExch.aculab.com> <1443450427.2531.2.camel@edumazet-glaptop2.roam.corp.google.com> <063D6719AE5E284EB5DD2968C1650D6D1CBA431C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'Neil Horman'" <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933868AbbI1RY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 13:24:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBA431C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2015 05:32 PM, David Laight wrote:
> From: Eric Dumazet
>> Sent: 28 September 2015 15:27
>> On Mon, 2015-09-28 at 14:12 +0000, David Laight wrote:
>>> From: Neil Horman
>>>> Sent: 28 September 2015 14:51
>>>> On Mon, Sep 28, 2015 at 02:34:04PM +0200, Denys Vlasenko wrote:
>>>>> Seemingly innocuous sctp_trans_state_to_prio_map[] array
>>>>> is way bigger than it looks, since
>>>>> "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
>>>>>
>>>>> This patch replaces it with switch() statement.
>>>
>>> What about just adding 1 (and masking) before indexing the array?
>>> That might require a static inline function with a local static array.
>>>
>>> Or define the array as (say) [16] and just mask the state before using
>>> it as an index?
>>
>> Just let the compiler do its job, instead of obfuscating source.
>>
>> Compilers can transform a switch into an (optimal) table if it is really
>> a gain.
> 
> The compiler can choose between a jump table and nested ifs for a switch
> statement. I've never seen it convert one into a data array index.

I don't know why people are fixated on a lookup table here.

For just four possible values, the amount of generated code
is less than one Icache cacheline.

Instruction cachelines are efficiently prefetched and branches
are predicted on all modern CPUs.
Possible data access for lookup table can not be prefetched
as efficiently.
