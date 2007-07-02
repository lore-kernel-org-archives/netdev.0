From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 08:54:49 -0700
Message-ID: <46891FC9.9060307@intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org> <46890B39.4050909@linux.intel.com> <46890E7C.9070204@garzik.org> <46891939.2030805@intel.com> <46891A99.7090003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18413 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690AbXGBPyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 11:54:51 -0400
In-Reply-To: <46891A99.7090003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Maybe this is not most important for ixgbe, where we only have 8 or so 
>> flags, but the new e1000 driver that I posted this weekend currently has 
>> 63 (you wanted flags ;)) of them. Do you want me to use 63 integers or 
>> just 2 ?
> 
> Don't be silly.  We are talking about single-bit feature flags 
> implemented using machine ints (a la tg3 with 32 flags per int), versus 
> bitfields.

tg3.c:

	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) ||
	    (tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND))

is obviously _not_ easier to read than

         if (tp->tg3_flags.pcix_target_hwbug || tp->tg3_flags.ich_workaround)

you even have to cascade your flags into a second integer, prone to error and 
confusion!

I would say that this method is definately worse for readability. I would much 
rather then stick with 'bool' instead.


Auke
