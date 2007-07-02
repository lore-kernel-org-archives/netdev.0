From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 07:41:54 -0700
Message-ID: <46890EB2.6070507@linux.intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org> <46890B39.4050909@linux.intel.com> <46890E7C.9070204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:13821 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755163AbXGBOnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 10:43:43 -0400
In-Reply-To: <46890E7C.9070204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> It's simple logic:  using machine integers are the easiest for the 
> compiler to Do The Right Thing, the easiest way to eliminate endian 
> problems, the easiest way for programmers to read and understand struct 
> alignment.

using integers pure is obviously natural..
but using integers and then manually doing bit masking yourself... 
that's not fundamentally better than what the compiler can do.

yes bitfields are hard for not-1-bit cases and for cases where you 
mimick hardware layouts. neither is the case in this code.
The code gets actually harder to read for the feature flags if you 
don't use bitfields....  so unless the code is really worse (and so 
far I've not seen that, but I'll investigate more when I get to work), 
I think it's fair to use single-bit, non-packed bitfields for them...
