From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 7 Jan 2010 06:35:46 +0000
Message-ID: <20100107063545.GA6258@ff.dom.local>
References: <20100106.202701.161194890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mikem@ring3k.org, shemminger@vyatta.com, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net, mbreuer@majjas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:43053 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab0AGGfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 01:35:53 -0500
Received: by fxm25 with SMTP id 25so11384190fxm.21
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2010 22:35:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100106.202701.161194890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-01-2010 05:27, David Miller wrote:
> From: Mike McCormack <mikem@ring3k.org>
> Date: Thu, 31 Dec 2009 19:55:31 +0900
> 
>> netif_device_detach() does not take the tx_lock, so it's
>>  possible that a call to sky2_xmit_frame is still in
>>  progress after netif_device_detach() is complete.
>>
>> Take netif_tx_lock() to make sure all transmits have
>>  stopped while we're disabling the devices and that
>>  no other CPU is still transmitting a frame after
>>  we've disabling the device.
>>
>> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
>>
>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> 
> Applied to net-next-2.6
> 
> Stephen has asked for some further refinements, once that is
> all sorted we can think about backporting this to net-2.6
> and -stable if necessary.
> 

David, I'm not sure you chose the right (working) patch from this
thread. Please, reconsider this:
Subject: [PATCH v2] sky2: Fix oops in sky2_xmit_frame() after TX timeout
Date: Mon, 4 Jan 2010 19:48:41 +0100
http://permalink.gmane.org/gmane.linux.network/148160

Thanks,
Jarek P.
