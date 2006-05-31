From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 11:41:27 -0700 (PDT)
Message-ID: <20060531.114127.14356069.davem@davemloft.net>
References: <20060531090301.GA26782@2ka.mipt.ru>
	<20060531035124.B3065@openss7.org>
	<20060531105814.GB7806@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6340
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S965083AbWEaSk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 14:40:57 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060531105814.GB7806@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 31 May 2006 14:58:18 +0400

> On Wed, May 31, 2006 at 03:51:24AM -0600, Brian F. G. Bidulock (bidulock@openss7.org) wrote:
> >   Worse: he folded the jenkins algorith result with
> > 
> >    h ^= h >> 16;
> >    h ^= h >> 8;
> > 
> >   Destroying the coverage of the function.
> 
> It was done to simulate socket code which uses the same folding.
> Leaving 32bit space is just wrong, consider hash table size with that
> index.

You absolutely show not do this shifting on the jenkins hash
result, you destroy the distribution entirely.  Just mask
it with the hash mask and that's all you need to do.

Brian is right, this is absolutely critical to using the Jenkins hash
correctly.  You're "unmixing" the bits it worked so hard to mix.

