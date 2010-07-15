From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Thu, 15 Jul 2010 08:59:17 -0700
Message-ID: <20100715085917.6a9cdd88@nehalam>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
	<1279204417.2118.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Junchang Wang <junchangwang@gmail.com>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44956 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932834Ab0GOP7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 11:59:19 -0400
In-Reply-To: <1279204417.2118.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jul 2010 15:33:37 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2010-07-15 at 22:24 +0800, Junchang Wang wrote:
> > Hi list,
> > My understand of the way that NICs deliver packets to the kernel is
> > as follows. Correct me if any of this is wrong. Thanks.
> > 
> > 1) The device buffer is fixed. When the kernel is acknowledged arrival of a 
> > new packet, it dynamically allocate a new skb and copy the packet into it. 
> > For example, 8139too.
> > 
> > 2) The device buffer is mapped by streaming DMA. When the kernel is 
> > acknowledged arrival of a new packet, it unmaps the region previously mapped. 
> > Obviously, there is NO memcpy operation. Additional cost is streaming DMA 
> > map/unmap operations. For example, e100 and e1000.
> > 
> > Here comes my question:
> > 1) Is there a principle indicating which one is better? Is streaming DMA
> > map/unmap operations more expensive than memcpy operation?
> 
> DMA should result in lower CPU usage and higher maximum performance.
> 
> > 2) Why does r8169 bias towards the first approach even if it support both? I 
> > convert r8169 to the second one and get a 5% performance boost. Below is result
> > running netperf TCP_STREAM test with 1.6K byte packet length.
> >         scheme 1    scheme 2    Imp.
> > r8169     683M        718M       5%
> [...]
> 
> You should also compare the CPU usage.

Also many drivers copy small receives into a new buffer
which saves space and often gives better performance.
