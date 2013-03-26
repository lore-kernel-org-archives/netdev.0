From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Tue, 26 Mar 2013 11:27:48 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71B6@saturn3.aculab.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com><1364209702-12437-6-git-send-email-wei.liu2@citrix.com><5150699C.6080209@citrix.com><CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com><51507C9B.3080109@citrix.com><CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com><51509789.8090608@citrix.com>	<20130325190911.GC7004@zion.uk.xensource.com> <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net> <6035A0D088A63A46850C3988ED045A4B3880B4F4@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <liuw@liuw.name>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <xen-devel@lists.xen.org>,
	<annie.li@oracle.com>
To: "James Harper" <james.harper@bendigoit.com.au>,
	"Paul Durrant" <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"David Vrabel" <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42621 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756792Ab3CZL3P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:29:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15671-07 for <netdev@vger.kernel.org>;
 Tue, 26 Mar 2013 11:29:13 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B3880B4F4@BITCOM1.int.sbss.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As stated previously, I've observed windows issuing staggering
> numbers of buffers to NDIS miniport drivers, so you will need
> to coalesce in a windows driver anyway. I'm not sure what the
> break even point is but I think it's safe to say that in the
> choice between using 1000 (worst case) ring slots (with the
> resulting mapping overheads) and coalescing in the frontend,
> coalescing is going to be the better option.

A long time ago we did some calculation on a sparc mbus/sbus
system (that has an iommu requiring setup for dma) and got
a breakeven point of (about) 1k.
(And I'm not sure we arrange to do aligned copies.)

Clearly that isn't directly relevant here...

It is even likely that the ethernet chips will underrun
if requested to do too many ring operations - especially
at their maximum speed.
I guess none of the modern ones require the first fragment
to be at least 100 bytes in order to guarantee retransmission
after a collision.

	David
