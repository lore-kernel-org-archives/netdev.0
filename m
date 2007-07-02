From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 10:25:49 -0400
Message-ID: <46890AED.7070906@garzik.org>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52079 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760146AbXGBOZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 10:25:52 -0400
In-Reply-To: <4689062A.8080809@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>  >> +    u32 alloc_rx_buff_failed;
>>> +    struct {
>>> +        unsigned int rx_csum_enabled    :1;
>>> +        unsigned int msi_capable    :1;
>>> +        unsigned int msi_enabled    :1;
>>> +        unsigned int msix_capable    :1;
>>> +        unsigned int msix_enabled    :1;
>>> +        unsigned int imir_enabled    :1;
>>> +        unsigned int in_netpoll        :1;
>>> +    } flags;
>>
>> always avoid bitfields.  They generate horrible code, and endian 
>> problems abound (though no endian problems are apparent here).
> 
> they generate no worse code than open coding the checks for these 
> feature flags...

That would be the logical assumption, but reality does not bear that 
logic out to be true.

I'm not sure whether gcc is confused about ABI alignment or such, on 
various platforms, but every time I look at the asm generated it is 
/not/ equivalent to open-coded feature flags and bitwise logic.  Often 
it is demonstrably worse.

The same is true for icc too :)  Bitfields are just bad juju for 
compilers, I guess.

	Jeff



