From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and private channels
Date: Thu, 18 Dec 2008 10:27:56 -0700
Message-ID: <e9c3a7c20812180927q7488f8b9n9641cf313363fcc5@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D70C8F3406@irsmsx504.ger.corp.intel.com>
	 <e9c3a7c20812151555g14080561q18cf2d0db4c1813b@mail.gmail.com>
	 <129600E5E5FB004392DDC3FB599660D70C984F6A@irsmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:59359 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbYLRR16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 12:27:58 -0500
In-Reply-To: <129600E5E5FB004392DDC3FB599660D70C984F6A@irsmsx504.ger.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 7:33 AM, Sosnowski, Maciej
<maciej.sosnowski@intel.com> wrote:
> What about situation, where some or all "public" channels in the system
> have been claimed by one client for its exclusive usage
> before another client appears trying to use available "public" channels?
> Despite of presence in the system of channels that supposed to be "public",
> the second cilent realizes that the channels are not available anymore at all
> or at least limited...
> Doesn't it contradict the general idea of "public" (general purpose) channels?
>

If a greedy module comes along and grabs all the channels via
dma_request_channel() then yes, there will be nothing left for the
public pool.  So, there is a requirement to "play nice".  If this
becomes an issue in practice we could add a DMA_NO_PRIVATE flag to
reserve a channel for public-only usage.

Regards,
Dan
