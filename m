From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary
 address creation
Date: Wed, 2 Apr 2008 08:56:39 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0804020849410.29568@netcore.fi>
References: <20080401215657.GP475@pirzuine> <20080402.084114.60517414.yoshfuji@linux-ipv6.org> <20080402001706.GD32592@pirzuine> <20080402.092514.75146790.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: benoit.boissinot@ens-lyon.org, netdev@vger.kernel.org
To: =?ISO-2022-JP?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28J?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:53437 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbYDBF5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 01:57:17 -0400
In-Reply-To: <20080402.092514.75146790.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Apr 2008, YOSHIFUJI Hideaki / ???? wrote:
>> Why not just simply round it above:
>> elapsed = (now - ifp->tstamp + HZ - 1) / HZ; /* round it up */
>> and the rest stays the same.
>>
>> Or do we care about having a lifetime a little bit (<1s) shorter ?
>
> Yes, I do.

Did I understand correctly that this issue is about the 0..1second 
interval being (for simplicity sake) being a bit shorter than exactly 
1 second?

Is there a good reason why this would be a problem?

I observe that the granularity (and I one could argue the accuracy) of 
Valid/Preferred Lifetime information is one second, so I'm not sure if 
the user should expect accuracy that's much finer than that (e.g. 0.1 
seconds).  Typically Valid/Preferred lifetimes are configured to be in 
the order of hours or even days, so what happens (with 0.1-0.01 second 
accuracy) during the last second doesn't seem very interesting from 
the practical point of view.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
