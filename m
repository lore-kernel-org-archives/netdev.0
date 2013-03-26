From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 11:38:20 +0000
Message-ID: <291EDFCB1E9E224A99088639C4762022013F7D8E0E14@LONPMAILBOX01.citrite.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
	<51509789.8090608@citrix.com>	<20130325190911.GC7004@zion.uk.xensource.com>
 <291EDFCB1E9E224A99088639C4762022013F7D8E0DC6@LONPMAILBOX01.citrite.net>
 <6035A0D088A63A46850C3988ED045A4B3880B4F4@BITCOM1.int.sbss.com.au>
 <291EDFCB1E9E224A99088639C4762022013F7D8E0E06@LONPMAILBOX01.citrite.net>
 <6035A0D088A63A46850C3988ED045A4B3880B6AE@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>, Wei Liu <liuw@liuw.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: James Harper <james.harper@bendigoit.com.au>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:58237 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757217Ab3CZLiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:38:12 -0400
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B3880B6AE@BITCOM1.int.sbss.com.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: James Harper [mailto:james.harper@bendigoit.com.au]
> Sent: 26 March 2013 11:29
> To: Paul Durrant; Wei Liu; David Vrabel
> Cc: Ian Campbell; Wei Liu; netdev@vger.kernel.org;
> konrad.wilk@oracle.com; xen-devel@lists.xen.org; annie.li@oracle.com
> Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
> copying
> 
> > > As stated previously, I've observed windows issuing staggering numbers
> of
> > > buffers to NDIS miniport drivers, so you will need to coalesce in a
> windows
> > > driver anyway. I'm not sure what the break even point is but I think it's
> safe
> > > to say that in the choice between using 1000 (worst case) ring slots (with
> > > the
> > > resulting mapping overheads) and coalescing in the frontend, coalescing
> is
> > > going to be the better option.
> > >
> >
> > Oh quite, if the backend is mapping and not copying then coalescing in the
> > frontend is the right way to go. I guess coalescing once the frag count
> > reaches a full ring count is probably necessary (since we can't push a partial
> > packet) but it would be nice not to have to do it if the backend is going to
> > copy anyway.
> >
> 
> For a 9k packet with 100 frags (not a common case, but an example), what is
> the cost of mapping those 100 frags into the backend vs coalescing to three
> pages in the frontend and mapping those?
> 
> I may be misremembering but wasn't there a patch floating around for
> persistent mapping to avoid some of this overhead? (not applicable here but
> I thought it meant that the cost wasn't insignificant)
> 

The current version of netback does not map, it always grant-copies.

  Paul
