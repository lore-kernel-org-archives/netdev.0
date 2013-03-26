From: James Harper <james.harper@bendigoit.com.au>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 11:15:13 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B3880B5B5@BITCOM1.int.sbss.com.au>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
	<51509789.8090608@citrix.com> <20130325190911.GC7004@zion.uk.xensource.com>
  <6035A0D088A63A46850C3988ED045A4B3880B43D@BITCOM1.int.sbss.com.au>
 <5151812F.3080905@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <liuw@liuw.name>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.bendigoit.com.au ([203.16.207.99]:56134 "EHLO
	smtp2.bendigoit.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080Ab3CZLPV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:15:21 -0400
In-Reply-To: <5151812F.3080905@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> On 26/03/13 10:52, James Harper wrote:
> >>> It's not clear why 19 or 20 were suggested as possible values.
> >>> I checked back to 2.6.18 and MAX_SKB_FRAGS there is
> >>> (65536/PAGE_SIZE + 2)
> >>
> >> Because the check is >= MAX_SKB_FRAGS originally and James Harper
> >> told me that "Windows stops counting on 20".
> >>
> >
> > I've obviously not been clear enough here... GPLPV stopped counting
> > at 20 (only needed to know if <20 or not). Windows itself can submit
> > a packet to NDIS with hundreds of buffers. It doesn't really matter
> > if it's 21 or 1021, I just didn't want to be misquoted.
> 
> This still isn't clear.  What's the maximum number of ring entries that
> GPLPV driver will use per packet?  Are you saying it's 20?  If so how
> has the GPLPV driver ever worked well with Linux's netback (with its
> historical limit of 18)?
> 

GPLPV will limit to 19, which I thought was the historic Linux limit but obviously not. I'd better look in to that.

I added a debug statement to catch what Windows would give to GPLPV, and it seemed that the maximum was 20, but then I double checked and GPLPV only needs to know if there are >19 frags or not, so it stops counting at 20. The actual number Windows will use internally is not limited so coalescing is required, and no sane amount of bumping up the Linux limit will reduce the requirement that a Windows driver will need to coalesce.

James
