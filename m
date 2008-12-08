From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the module level
Date: Mon, 8 Dec 2008 15:39:01 -0700
Message-ID: <e9c3a7c20812081439m8161812nca092e0ed3114e57@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
	 <Pine.LNX.4.64.0812041746400.5079@axis700.grange>
	 <e9c3a7c20812041051l44bd8086o97c12d77a116f62@mail.gmail.com>
	 <Pine.LNX.4.64.0812041959530.8851@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	nicolas.ferre@atmel.com
To: "Guennadi Liakhovetski" <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:47889 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbYLHWjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 17:39:02 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1485285wfd.4
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 14:39:01 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0812041959530.8851@axis700.grange>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2008 at 12:28 PM, Guennadi Liakhovetski
<g.liakhovetski@gmx.de> wrote:
> Ok, but why not postpone calling .device_alloc_chan_resources() until a
> channel is _found_?

dma_find_channel() is called in fast paths (atomic contexts, I/O
writeout), so we need to allocate ahead of time.
