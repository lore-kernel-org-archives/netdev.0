From: akepner@sgi.com
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 17:11:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
References: <200608080711.06788.ak@suse.de> <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain>
 <200608090123.01123.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: ak@suse.de, kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:8143 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1030369AbWHIAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 20:21:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.171152.58440635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2006, David Miller wrote:

> From: Andi Kleen <ak@suse.de>
> Date: Wed, 9 Aug 2006 01:23:01 +0200
>
>> The problem is to find out what a good boundary is.
>
> The more I think about this the more I lean towards
> two conclusions:
>
> 1) dynamic table growth is the only reasonable way to
>   handle this and not waste memory in all cases
> ....

Definitely that's the ideal way to go.

But there's alot of state to update (more or less
atomically, too) in the TCP hashes. Looks tricky to
do that without hurting performance, especially since
you'll probably want to resize the tables when you've
discovered they're full and busy....

-- 
Arthur


