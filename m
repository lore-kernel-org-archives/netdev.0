From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Fri, 16 Mar 2007 10:03:04 -0700
Message-ID: <20070316100304.4eca9907@freekitty>
References: <20070312210907.509184287@linux-foundation.org>
	<20070315021840.GG1246@kvack.org>
	<45F8E793.7040603@cosmosbay.com>
	<20070315.002516.59485075.davem@davemloft.net>
	<20070315131722.GH1246@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53006 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965706AbXCPREc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 13:04:32 -0400
In-Reply-To: <20070315131722.GH1246@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Mar 2007 09:17:22 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Thu, Mar 15, 2007 at 12:25:16AM -0700, David Miller wrote:
> > Could we obtain %rip relative addressing with the ELF
> > relocation approach I mentioned?
> 
> I think we can for some of the objects -- things like slab caches are 
> good candidates if we have the initialization done at init time, which 
> would actually be a very cool way of getting rid of the static slab 
> creation calls.  I'll cook something better up on the slab front.
> 
> As for other variables, many can't be rip relative as they often end up 
> pointing to addresses outside of the +/-2GB range we have there.
> 
> The main reason I came up with this was from looking at the various 
> kprobes and notifier chain overhead in common code paths.  In many 
> instances we need a single byte flag showing the feature is in use to 
> jump out of the hot path.
> 
> Then there are the selinux hooks....
> 
> 		-ben

There is an ugliness and maintenance vs performance tradeoff here.
The described implementation leaves me gagging. Is there some way
to do the same thing with ELF sections and post build processing?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
