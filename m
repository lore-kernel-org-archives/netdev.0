From: James Harper <james.harper@bendigoit.com.au>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 11:00:43 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B3880B4F4@BITCOM1.int.sbss.com.au>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
	<51509789.8090608@citrix.com>	<20130325190911.GC7004@zion.uk.xensource.com>
 <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>, Wei Liu <liuw@liuw.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.bendigoit.com.au ([203.16.207.99]:55938 "EHLO
	smtp2.bendigoit.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3CZLAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:00:54 -0400
In-Reply-To: <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Because the check is >= MAX_SKB_FRAGS originally and James Harper told
> > me that "Windows stops counting on 20".
> >
> 
> For the Citrix PV drivers I lifted the #define of MAX_SKB_FRAGS from the
> dom0 kernel (i.e. 18). If a packet coming from the stack has more than that
> number of fragments then it's copied and coalesced. The value advertised
> for TSO size is chosen such that a maximally sized TSO will always fit in 18
> fragments after coalescing but (since this is Windows) the drivers don't trust
> the stack to stick to that limit and will drop a packet if it won't fit.
> 
> It seems reasonable that, since the backend is copying anyway, that it should
> handle any fragment list coming from the frontend that it can. This would
> allow the copy-and-coalesce code to be removed from the frontend (and the
> double-copy avoided). If there is a maximum backend packet size though
> then I think this needs to be advertised to the frontend. The backend should
> clearly bin packets coming from the frontend that exceed that limit but
> advertising that limit in xenstore allows the frontend to choose the right TSO
> maximum size to advertise to its stack, rather than having to make it based
> on some historical value that actually has little meaning (in the absence of
> grant mapping).
> 

As stated previously, I've observed windows issuing staggering numbers of buffers to NDIS miniport drivers, so you will need to coalesce in a windows driver anyway. I'm not sure what the break even point is but I think it's safe to say that in the choice between using 1000 (worst case) ring slots (with the resulting mapping overheads) and coalescing in the frontend, coalescing is going to be the better option.

James
