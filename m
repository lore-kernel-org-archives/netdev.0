From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Mon, 18 Nov 2013 17:52:38 -0500
Message-ID: <528A9A36.50903@pobox.com>
References: <52890C7E.6000607@pobox.com> <52891178.2080509@pobox.com> <52891341.4020403@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742B@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ming Lei <ming.lei@canonical.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:53554 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3KRWwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 17:52:40 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-18 08:32 AM, David Laight wrote:
>> From: David Laight
>>> On 13-11-17 01:56 PM, Mark Lord wrote:
>>>> On 13-11-17 01:35 PM, Mark Lord wrote:
>>>>> The USB3 network adapter locks up consistently for me here in 3.12,
>>>>> but was working without issues in 3.11.x
>>
>> The xhci driver is well broken in 3.12.
> 
> To correct myself...
> 
> The xhci driver has never correctly support scatter-gather requests.
> In 3.12 code was added to usbnet to generate SG transmits, and to the
> ax88179_178a driver to use them.
> TCP segmentation offload was then enabled - with does generate
> SG transfers.
> 
> SG transfers for 'disks' almost certainly work because the
> fragment boundaries are 'adequately aligned'.
> 
> 	David
> 

Well, that's all very nice and whatnot,
except the ax88179_178a driver still does not work in linux-3.12,
whereas it works fine in all earlier kernels.

That's a regression.
And a simple revert (earlier in this thread) fixes it.

So.. let's revert it for now, until a proper xhci compatible patch is produced.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
