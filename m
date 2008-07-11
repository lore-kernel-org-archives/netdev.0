From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Thu, 10 Jul 2008 17:53:34 -0700
Message-ID: <4876AF0E.507@qualcomm.com>
References: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>	<200807091759.39171.borntraeger@de.ibm.com>	<48752B60.4050106@qualcomm.com> <20080710.170007.68764077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: borntraeger@de.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:9061 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877AbYGKAxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 20:53:35 -0400
In-Reply-To: <20080710.170007.68764077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Max Krasnyansky <maxk@qualcomm.com>
> Date: Wed, 09 Jul 2008 14:19:28 -0700
> 
>> Christian Borntraeger wrote:
>>> Am Mittwoch, 9. Juli 2008 schrieb Max Krasnyansky:
>>>> The scenario goes like this. App stops reading from tun/tap.
>>>> TX queue gets full and driver does netif_stop_queue().
>>>> App closes fd and TX queue gets flushed as part of the cleanup.
>>>> Next time the app opens tun/tap and starts reading from it but
>>>> the xoff state is not cleared. We're stuck.
>>>> Normally xoff state is cleared when netdev is brought up. But
>>>> in the case of persistent devices this happens only during
>>>> initial setup.
>>> I was able to reproduce the problem. The patch seems to fix it.
>>>
>>> Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> Oh it definitely fixes that problem. It's very easy to reproduce by just 
>> suspending (ctrl-z) an app that is ready from the tun, waiting a bit for 
>> the queue to fill up and then killing the app. I have a simple test app 
>> that simulates this. It's just that in real life that does not happen 
>> very often. ie Applications either constantly read from tun or they 
>> close it.
>>
>> Thanks a lot for testing and confirming.
> 
> I've applied this, thanks.
> 
> But I had to apply it by hand.  You made this against an older
> tree, because in the current code there is a get_net() call
> right before the new lines you added but in your patch context
> it isn't there.

Hmm, I though I used latest git tree. Oh, turns out it was 2.6.25.4. 
Sorry. Thanx for fixing it.

Max



