From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Tue, 26 Mar 2013 11:06:23 +0000
Message-ID: <5151812F.3080905@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>	<5150699C.6080209@citrix.com>	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>	<51507C9B.3080109@citrix.com>	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>	<51509789.8090608@citrix.com> <20130325190911.GC7004@zion.uk.xensource.com>  <6035A0D088A63A46850C3988ED045A4B3880B43D@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <liuw@liuw.name>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: James Harper <james.harper@bendigoit.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37887 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753717Ab3CZLG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 07:06:26 -0400
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B3880B43D@BITCOM1.int.sbss.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/13 10:52, James Harper wrote:
>>> It's not clear why 19 or 20 were suggested as possible values.
>>> I checked back to 2.6.18 and MAX_SKB_FRAGS there is
>>> (65536/PAGE_SIZE + 2)
>> 
>> Because the check is >= MAX_SKB_FRAGS originally and James Harper
>> told me that "Windows stops counting on 20".
>> 
> 
> I've obviously not been clear enough here... GPLPV stopped counting
> at 20 (only needed to know if <20 or not). Windows itself can submit
> a packet to NDIS with hundreds of buffers. It doesn't really matter
> if it's 21 or 1021, I just didn't want to be misquoted.

This still isn't clear.  What's the maximum number of ring entries that
GPLPV driver will use per packet?  Are you saying it's 20?  If so how
has the GPLPV driver ever worked well with Linux's netback (with its
historical limit of 18)?

David
