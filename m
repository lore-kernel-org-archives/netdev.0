From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 15:05:17 -0700 (PDT)
Message-ID: <20090519.150517.62361946.davem@davemloft.net>
References: <20090519162048.GB28034@hmsreliant.think-freely.org>
	<4A12FEDA.7040806@cosmosbay.com>
	<20090519192450.GF28034@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722AbZESWFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:05:19 -0400
In-Reply-To: <20090519192450.GF28034@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 19 May 2009 15:24:50 -0400

>> Moving whole group in front would defeat the purpose of move, actually,
>> since rank in chain is used to decay the timeout in garbage collector.
>> (search for tmo >>= 1; )
>> 
> Argh, so the list is implicitly ordered by expiration time.  That
> really defeats the entire purpose of doing grouping in the ilst at
> all.  If thats the case, then I agree, its probably better to to
> take the additional visitation hit in in check_expire above than to
> try and preserve ordering.

Yes, this seems best.

I was worried that somehow the ordering also influences lookups,
because the TOS bits don't go into the hash so I worried that it would
be important that explicit TOS values appear before wildcard ones.
But it doesn't appear that this is an issue, we don't have wildcard
TOSs in the rtable entries, they are always explicit.

So I would like to see an explicit final patch from Eric so we can get
this fixed now.

Thanks!
