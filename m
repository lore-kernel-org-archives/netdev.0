From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Thu, 15 Mar 2007 09:17:22 -0400
Message-ID: <20070315131722.GH1246@kvack.org>
References: <20070312210907.509184287@linux-foundation.org> <20070315021840.GG1246@kvack.org> <45F8E793.7040603@cosmosbay.com> <20070315.002516.59485075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:54009 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933541AbXCONRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 09:17:36 -0400
Content-Disposition: inline
In-Reply-To: <20070315.002516.59485075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 12:25:16AM -0700, David Miller wrote:
> Could we obtain %rip relative addressing with the ELF
> relocation approach I mentioned?

I think we can for some of the objects -- things like slab caches are 
good candidates if we have the initialization done at init time, which 
would actually be a very cool way of getting rid of the static slab 
creation calls.  I'll cook something better up on the slab front.

As for other variables, many can't be rip relative as they often end up 
pointing to addresses outside of the +/-2GB range we have there.

The main reason I came up with this was from looking at the various 
kprobes and notifier chain overhead in common code paths.  In many 
instances we need a single byte flag showing the feature is in use to 
jump out of the hot path.

Then there are the selinux hooks....

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
