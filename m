From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Tue, 22 Dec 2015 22:50:04 +0100
Message-ID: <5679C58C.2090308@stressinduktion.org>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56444 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933305AbbLVVuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:50:09 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 5EC7F20C2B
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 16:50:08 -0500 (EST)
In-Reply-To: <20151222212843.GE4424@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marc,

On 22.12.2015 22:28, Marc Haber wrote:
> Hi Hannes,
> 
> thanks for your mail.
> 
> On Tue, Dec 22, 2015 at 04:15:14PM +0100, Hannes Frederic Sowa wrote:
>> On 12.12.2015 20:58, Marc Haber wrote:
>>> Any hints would be appreciated.
>>
>> This sysctl should help:
>>
>> accept_ra_from_local - BOOLEAN
>>         Accept RA with source-address that is found on local machine
>>         if the RA is otherwise proper and able to be accepted.
>>         Default is to NOT accept these as it may be an un-intended
>>         network loop.
>>
>>         Functional default:
>>            enabled if accept_ra_from_local is enabled
>>                on a specific interface.
>>            disabled if accept_ra_from_local is disabled
>>                on a specific interface.
>>
>> Anyway, this has to be fixed up in a clean way and should work by default.
> 
> The clean way would be:
> 
> accept_ra_from_local=0: never accept RA with source-address that is
>   found on local machine
> accept_ra_from_local=1: always accept RA with source-address that is
>   found on local machine. Dangerous.
> accept_ra_from_local=2: only accept RA with link local source-address
>   that is found on local machine, and not if received RA points to an
>   address that is locally configured on the same interface. Default.
> 
> Shall I file a bug for this in bugzilla?

Thanks but no need to do that, I already cooked a patch and will submit
tomorrow after some testing. We don't need to enhance the sysctl,
default should be to simply check the interface too if a route with
link-local address is received.

Bye,
Hannes
