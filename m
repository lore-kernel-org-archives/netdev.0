From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Wed, 07 May 2014 16:44:34 -0400 (EDT)
Message-ID: <20140507.164434.997979341700998470.davem@davemloft.net>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
	<20140507.155613.630399521517455317.davem@davemloft.net>
	<20140507203317.GC8786@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaEGUoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:44:38 -0400
In-Reply-To: <20140507203317.GC8786@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 7 May 2014 16:33:17 -0400

> Perhaps a solution is a signalling mechanism tied to completion interrupts?
> I.e. a mapping failure gets reported to the stack, which causes the
> correspondnig queue to be stopped, until such time a the driver signals a safe
> restart by the reception of a tx completion interrupt?  I'm actually tinkering
> right now with a mechanism that provides guidance to the stack as to how many
> dma descriptors are available in a given net_device that might come in handy
> here

Another idea is to signal it from the IOMMU unmap itself, since that is the
point where the resource becomes available.

Actually either approach is fine with me.
