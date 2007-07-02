From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 08:26:49 -0700
Message-ID: <46891939.2030805@intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org> <46890B39.4050909@linux.intel.com> <46890E7C.9070204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26852 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbXGBP0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 11:26:51 -0400
In-Reply-To: <46890E7C.9070204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Arjan van de Ven wrote:
>> Jeff Garzik wrote:
>>>>> always avoid bitfields.  They generate horrible code, and endian 
>>>>> problems abound (though no endian problems are apparent here).
>>>> they generate no worse code than open coding the checks for these 
>>>> feature flags...
>>> That would be the logical assumption, but reality does not bear that 
>>> logic out to be true.
>>>
>> I just checked a small example and gcc just generates a testb with an 
>> immediate value, which isn't all that bad code.
>>
>> Do you remember which gcc you tested with?
> 
> gcc 2.95, gcc 3.x, gcc 4.x, ...  on multiple architectures, not just ia32.
> 
> It's simple logic:  using machine integers are the easiest for the 
> compiler to Do The Right Thing, the easiest way to eliminate endian 
> problems, the easiest way for programmers to read and understand struct 
> alignment.

I really disagree with you here, I much rather prefer using code style like:

   if (adapter->flags.msi_enabled) ..

than

   if (adapter->flags & E1000_FLAG_MSI_ENABLED) ...

not only does it read easier, it's also shorter and not prone to &/&& confusion 
typo's, takes away parentheses when the test has multiple parts etc...

Maybe this is not most important for ixgbe, where we only have 8 or so flags, 
but the new e1000 driver that I posted this weekend currently has 63 (you wanted 
flags ;)) of them. Do you want me to use 63 integers or just 2 ?

And as Arjan said, we're not passing any of these to hardware, so there should 
not be any endian issues.

I think acme would agree with me that pahole currently is the easiest way to 
show struct alignment ...


Auke
