From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 23 Sep 2008 11:07:58 +0400
Message-ID: <20080923070758.GD25231@2ka.mipt.ru>
References: <20080922070425.GA14572@2ka.mipt.ru> <E1Khzut-0006lv-Co@gondolin.me.apana.org.au> <20080923062709.GA7886@2ka.mipt.ru> <20080923070133.GB26836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johaahn@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:44934 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753092AbYIWHI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 03:08:58 -0400
Content-Disposition: inline
In-Reply-To: <20080923070133.GB26836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 03:01:33PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Yes but bulk transfers over UDP is a bad idea regardless of how
> slow your bus is :)

It still deserves living if it is not highly priority traffic like video
dataflow.

> So what application needs this?

Johann did not show his exact usage scenario, but from what I got I
concluded, that it is kind of a video sensor (or some other data which
is allowed to be lost), which has to add a header
to the frame and submit it to the network without any copy because of
hardware limitation for the memory bus. Sensor can put data via DMA to
the needed location. His first (and parallel to this one) idea was to
extend packet socket to allow send of the mapped data.
I proposed to do the same with sendfile, i.e. dma data to the mapped
area of some file in the ramdisk, add header, do it for multiple frames
and then send given file using sendfile().

-- 
	Evgeniy Polyakov
