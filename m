From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6 addrconf: Implemented enhanced DAD (RFC7527)
Date: Mon, 21 Nov 2016 23:46:44 +0100
Message-ID: <b30897ea-5372-45c6-e8af-f85671fc29bf@stressinduktion.org>
References: <5863cb78-0050-7b7e-f886-d4d6b2186f16@sonic.net>
 <1ba995e1-2af9-ce9b-7038-e8463dd2a0a8@stressinduktion.org>
 <99c143c3-9ec5-0f5f-44ed-6a4c60e723d8@sonic.net>
 <b9854c18-f71c-2e71-d352-531bca72eeb4@stressinduktion.org>
 <ff28e755-be89-c5de-8e1b-3f6adfb1225a@sonic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Erik Nordmark <nordmark@sonic.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54966 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754386AbcKUWqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 17:46:47 -0500
In-Reply-To: <ff28e755-be89-c5de-8e1b-3f6adfb1225a@sonic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 21.11.2016 18:10, Erik Nordmark wrote:
> On 11/16/16 10:49 PM, Hannes Frederic Sowa wrote:
>> I thought about even removing the sysctl altogether and enable enhanced
>> DAD by default. ;)
>>
>> I am in favor of enabling it by default.
>>
>> But given that there could be broken implementations out there, we
>> should give users a choice and provide.
> OK, I'll make it the default and send out a new version of the patch. I
> was told I should base the patch on net-next instead of linux-stable so
> I'll move it there.

Correct.

>>
>> Could you always generate a nonce in the interface structure? You could
>> check the sysctl in the send and receive path to attach and check the
>> nonce. This has the advantage that you don't need to delete the
>> interface and recreate it to enable/disable enhanced dad on an interface
>> (also you can get away with the loop around get_random_bytes to make
>> sure its value is not zero as we don't depend on a non-zero nonce
>> variable to signal enaling of the feature, see below).
> The nonce is per interface address and not per interface. Furthermore,
> the RFC says that on a retry of DAD the nodes will end up using a
> different nonce implying that even for the same interface address it
> should pick a different nonce for each DAD attempt.
> Note that since there is no automatic retry of DAD (per RFC4862) and
> each try would check the current sysctl setting so I don't think
> pre-generating the nonce would change the behavior.

Sorry for misreading the code then. ;) Indeed, I don't see a problem
with your proposal.

Thanks,
Hannes
