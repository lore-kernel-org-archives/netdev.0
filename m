From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 02/13] ixgbe: Adding Tx encapsulation capability
Date: Wed, 30 Jan 2013 16:59:40 -0800
Message-ID: <5109C1FC.5010704@gmail.com>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1359546286-18179-3-git-send-email-jeffrey.t.kirsher@intel.com>  <51095146.7030404@intel.com> <1359568103.30177.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39381 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527Ab3AaA7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 19:59:43 -0500
Received: by mail-pa0-f45.google.com with SMTP id bg2so1405404pad.32
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 16:59:42 -0800 (PST)
In-Reply-To: <1359568103.30177.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2013 09:48 AM, Eric Dumazet wrote:
> On Wed, 2013-01-30 at 08:58 -0800, Alexander Duyck wrote:
>> NAK, this is not a production patch.  This was just meant to be proof of
>> concept code.
> Well, this was the most interesting part of this serie for me ;)
>
> What is missing to reach production level ?

Well this was sort of a hack in the first place.  I am just treating the
outer headers as one giant L2 header in order to allow this to work.

> hw_enc_features is in net-next with no user yet, I was eager to see
> the first implementation...
>
> if (skb->encapsulation)
> 	features &= dev->hw_enc_features;

Really the feature was meant for the next gen hardware, not the current
gen.  The fact is you can apply this patch and test with it, but you
could probably do the same hack on most network drivers in order to make
them capable of doing the transmit checksum on the inner header for
VXlan frames.

The other issue is this patch was pretty much just meant to allow
testing the feature to make sure it was setup correctly in the kernel
and as such I had advised our testers to only focus on bugs in the
kernel enablement code and not the code enabling the offload in ixgbe.

Thanks,

Alex
