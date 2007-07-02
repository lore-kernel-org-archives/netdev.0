From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Mon, 02 Jul 2007 12:09:58 -0400
Message-ID: <46892356.9010209@garzik.org>
References: <20070612234417.5102.29147.stgit@localhost.localdomain>	<20070612234431.5102.33880.stgit@localhost.localdomain>	<4688F512.3030801@garzik.org>	<4689062A.8080809@linux.intel.com>	<46890AED.7070906@garzik.org>	<46890B39.4050909@linux.intel.com>	<46890E7C.9070204@garzik.org>	<46891939.2030805@intel.com>	<46891A99.7090003@garzik.org> <20070702085258.6d09df16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52796 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725AbXGBQKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 12:10:03 -0400
In-Reply-To: <20070702085258.6d09df16.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Mon, 02 Jul 2007 11:32:41 -0400 Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Bitfields are to be avoided for many reasons:
>> * more difficult, in general, for a compiler to generate optimal code
>> * in particular, known to generate worse code on various architectures
>> * often causes endian problems
>> * often enhances programmer confusion, when trying to review structs and 
>> determine optimal layout and alignment
>> * programmers have proven they will screw up bitfields in e.g. cases 
>> with 1-bit and signedness.
>>
>> I can probably think up more reasons to avoid bitfields if given another 
>> 5 minutes :)
> 
> A significant problem is that modifications to "nearby" bitfields need
> locking: concurrent modifications to two bitfields can result in concurrent
> modifications to the same word.
> 
> And that's OK, but it's pretty unobvious that these stores are nonatomic
> from the source code and people could easily forget to do it.

Indeed.

Overall, it isn't any one specific thing that makes me reject bitfields 
in new code, it's the sum of all these reasons.

Kernel and compiler history proves that humans and compilers screw up 
bitfields early and often :)

Another reason that I just thought of:  bitfields cannot be 
conglomerated into easy-to-assign-and-test masks, making

	foo = (1 << 0),
	bar = (1 << 4),
	baz = (1 << 9),
	default_feature_flags = foo | bar | baz,

	foo->flags = default_feature_flags;

impossible with bitfields.

You also cannot test multiple bits at one time, with bitfields.


> That being said, they _are_ attractive from the nice-to-read POV...

My personal style disagrees, but that's a personal taste.  I can see how 
other people might think that, though, agreed.

	Jeff



