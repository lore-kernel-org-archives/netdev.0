From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Wed, 09 Jul 2008 14:19:28 -0700
Message-ID: <48752B60.4050106@qualcomm.com>
References: <1215584648-13444-1-git-send-email-maxk@qualcomm.com> <200807091759.39171.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:38607 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbYGIVT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 17:19:29 -0400
In-Reply-To: <200807091759.39171.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger wrote:
> Am Mittwoch, 9. Juli 2008 schrieb Max Krasnyansky:
>> The scenario goes like this. App stops reading from tun/tap.
>> TX queue gets full and driver does netif_stop_queue().
>> App closes fd and TX queue gets flushed as part of the cleanup.
>> Next time the app opens tun/tap and starts reading from it but
>> the xoff state is not cleared. We're stuck.
>> Normally xoff state is cleared when netdev is brought up. But
>> in the case of persistent devices this happens only during
>> initial setup.
> 
> I was able to reproduce the problem. The patch seems to fix it.
> 
> Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

Oh it definitely fixes that problem. It's very easy to reproduce by just 
suspending (ctrl-z) an app that is ready from the tun, waiting a bit for 
the queue to fill up and then killing the app. I have a simple test app 
that simulates this. It's just that in real life that does not happen 
very often. ie Applications either constantly read from tun or they 
close it.

Thanks a lot for testing and confirming.

Max
