From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH kernel 4/4] sh_eth: Fix DMA-API usage for RX buffers
Date: Sat, 28 Feb 2015 03:06:09 +0000
Message-ID: <1425092769.4444.102.camel@xylophone.i.decadent.org.uk>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
	 <1422319824.3524.24.camel@xylophone.i.decadent.org.uk>
	 <54F0D56B.8000809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:58607 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1DGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:06:14 -0500
In-Reply-To: <54F0D56B.8000809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 23:36 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/27/2015 03:50 AM, Ben Hutchings wrote:
> 
> > - Use the return value of dma_map_single(), rather than calling
> >    virt_to_page() separately
> > - Check for mapping failue
> > - Call dma_unmap_single() rather than dma_sync_single_for_cpu()
> 
> > Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> 
>     I wonder whether you're aware at the previous Renesas' attemept at fixing 
> DMA issues:
> 
> http://marc.info/?t=141586251000003

No, I only started looking at R-Car stuff in December.

>     It was turned down because they tried to deal with several issues in one 
> patch, and they have failed to follow up. Could you look at the rest of the 
> DMA issues reported (and not reported) in that patch?

Issue 1 should be fixed by "sh_eth: Check for DMA mapping errors on
transmit" and this one.

I don't think that issue 2 still applies but I also don't see how it was
fixed, so maybe I'm missing something.

Issue 3 should have been fixed by "sh_eth: Fix padding of short frames
on TX" except that I used the wrong padding function, so it also needs
"sh_eth: Really fix padding of short frames on TX".

Issue 4 should be fixed by this one.  Except that I forgot to add
unmapping in sh_eth_ring_free(), so RX DMA mappings are still leaked
when the device is taken down.

Ben.
