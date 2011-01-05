From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to
 correctly interpret string count
Date: Wed, 05 Jan 2011 17:28:06 +0000
Message-ID: <1294248486.15866.88.camel@bwh-desktop>
References: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>
	 <1294185662.3636.61.camel@bwh-desktop>  <4D23C423.3050609@intel.com>
	 <1294241216.15866.14.camel@bwh-desktop>  <4D24A2DD.2040603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35952 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab1AER2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:28:10 -0500
In-Reply-To: <4D24A2DD.2040603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-05 at 08:57 -0800, Alexander Duyck wrote:
[...]
> I'm fine with us replacing the ETHTOOL_GRXNTUPLE interface, but I would 
> prefer to do it after the merge windows for 2.6.39 has opened.  For now 
> I would like to get this patch accepted as my main concern is getting a 
> minor fix in versus rewriting the entire interface.

So long as there are no in-tree implementations of
ethtool_ops::get_rx_ntuple then it's a valid candidate for removal.
Since you now want to implement it, I think you should submit the
implementation along with the fix for the calling code.

> While we're at it how would you feel about us inverting the masks for 
> setting up an ntuple by making them an inclusion mask instead of an 
> exclusion one?  The reason why I ask is because I have to perform an and 
> operation over all the input anyway before I can use it to compute the 
> hashes and as such I am having to invert almost all of the mask bits, 
> and it appears you are having to do this as well for many of the masks 
> in sfc.

We can't change the userland interface but we could potentially invert
the masks in the ethtool core.  I'm really not convinced that this is
worth the trouble though.  (And it would be a massive pain for the OOT
versions of our drivers.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

