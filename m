From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 4/6] [IPROUTE2]: Overhead calculation is now done in the
 kernel
Date: Wed, 12 Sep 2007 17:07:41 +0100
Message-ID: <46E80ECD.8000605@andyfurniss.entadsl.com>
References: <1189592079.26927.25.camel@localhost.localdomain>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:36356 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932502AbXILQHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 12:07:33 -0400
In-Reply-To: <1189592079.26927.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> commit 07a74a2613440fc1a68d0faa7235ed7027532d78
> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> Date:   Tue Sep 11 16:59:58 2007 +0200
> 
>     [IPROUTE2]: Overhead calculation is now done in the kernel.
>     
>     The only current user is HTB. HTB overhead argument is now passed on
>     to the kernel (in the struct tc_ratespec). Also correct the data
>     types.

Thanks for getting this in.

It would be cool if mpu/overhead could be set per class > 255 and they 
would affect the way htb shares bandwidth.

I could be wrong but it doesn't look like this will change current 
behavior.Perhaps just allowing mpu/overhead > 255 for now, so that htb 
sharing could be fixed up in the future?

The use would be for ingress shaping, you could set a big mpu for an 
interactive class and it would cause bulk classes to get way less 
bandwidth than otherwise, so you wouldn't permanently have to sacrifice 
so much bandwidth on a slow link for latency - just when you needed to. 
It could also, with the aid of netfilter connbytes, be used to preempt 
the remote buffer filling when new bulk flows start.

One more thing, IIRC Devik acked your/Russels patch to change the 
HYSTERESIS define to 0 - any chance of resubmitting?

Thanks

Andy.

