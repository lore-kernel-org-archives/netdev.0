From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 16:33:05 -0500
Message-ID: <20060420213305.GK26746@pb15.lixom.net>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:61398 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1751315AbWDTVlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 17:41:14 -0400
To: Andrew Grover <andrew.grover@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 01:49:16PM -0700, Andrew Grover wrote:
> Hi I'm reposting these, originally posted by Chris Leech a few weeks ago.
> However, there is an extra part since I broke up one patch that was too 
> big for netdev last time into two (patches 2 and 3).
> 
> Of course we're always looking for more style improvement comments, but 
> more importantly we're posting these to talk about the larger issues 
> around I/OAT and this code making it in upstream at some point.
> 
> These are also available on the wiki,  
> http://linux-net.osdl.org/index.php/I/OAT .

Hi,

Since you didn't provide the current issues in this email, I will copy
and paste them from the wiki page.

I guess the overall question is, how much of this needs to be addressed
in the implementation before merge, and how much should be done when
more drivers (with more features) are merged down the road. It might not
make sense to implement all of it now if the only available public
driver lacks the abilities.   But I'm bringing up the points anyway.

Maybe it could make sense to add a software-based driver for reference,
and for others to play around with.

I would also prefer to see the series clearly split between the DMA
framework and first clients (networking) and the I/OAT driver. Right now
"I/OAT" and "DMA" is used interchangeably, especially when describing
the later patches. It might help you in the perception that this is
something unique to the Intel chipsets as well.  :-)

(I have also proposed DMA offload discussions as a topic for the Kernel
Summit. I have kept Chris Leech Cc:d on most of the emails in question. It
should be a good place to get input from other subsystems regarding what
functionality they would like to see provided, etc.)


>From the wiki:

> Current issues of concern:
>
>    1. Performance improvement may be on too narrow a set of workloads

Maybe from I/OAT and the current client, but the introduction of the
DMA infrastructure opens up for other uses that are not yet possible in
the API. For example, DMA with functions is a very natural extension,
and something that's very common on various platforms (XOR for RAID use,
checksums, encryption).

The API needs to be expanded to cover this by adding function types and
adding them to the channel allocation interface and logic.

>    2. Limited availability of hardware supporting I/OAT

DMA engines are fairly common, even though I/OAT might not be yet. They
just haven't had a common infrastructure until now.

For people who might want to play with it, a reference software-based
implementation might be useful.

>    3. Data copied by I/OAT is not cached

This is a I/OAT device limitation and not a global statement of the
DMA infrastructure. Other platforms might be able to prime caches
with the DMA traffic. Hint flags should be added on either the channel
allocation calls, or per-operation calls, depending on where it makes
sense driver/client wise.

>    4. Intrusiveness of net stack modifications
>    5. Compatibility with upcoming VJ net channel architecture 

Both of these are outside my scope, so I won't comment on them at this
time.


I would like to add, for longer term:

   * Userspace interfaces:
Are there any plans yet on how to export some of this to userspace? It
might not make full sense for just memcpy due to overheads, but it makes
sense for more advanced dma/offload engines.


-Olof
