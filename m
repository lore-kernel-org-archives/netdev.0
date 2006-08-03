From: David Miller <davem@davemloft.net>
Subject: Re: [take3 1/4] kevent: Core files.
Date: Thu, 03 Aug 2006 14:37:28 -0700 (PDT)
Message-ID: <20060803.143728.43853414.davem@davemloft.net>
References: <11545983603399@2ka.mipt.ru>
	<200608031640.34513.dada1@cosmosbay.com>
	<20060803145553.GA12915@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43188
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932546AbWHCViK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:38:10 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060803145553.GA12915@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 3 Aug 2006 18:55:57 +0400

> I would not call that wrong - system prevents some threads from removing 
> kevents which are counted to be transfered to the userspace, i.e. when 
> dequeuing was awakened and it had seen some events it is possible, that 
> when it will dequeue them part will be removed by other thread, so I 
> prevent this.

Queue is all that matters to be synchronized, so it seems
better to have a mutex on the queue rather than a global
one.  That way, user can only hurt himself.
