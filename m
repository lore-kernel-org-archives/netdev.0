From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 4/4] xen-netback: coalesce slots before
 copying
Date: Fri, 22 Mar 2013 11:06:00 +0000
Message-ID: <20130322110600.GA5742@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
 <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
 <6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
 <6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
 <CAOsiSVWSRmo1+Ubo7GyAKcvUr8XUenkMvnAqt607gPoJm-sXFQ@mail.gmail.com>
 <6035A0D088A63A46850C3988ED045A4B387FB199@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <liuw@liuw.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: James Harper <james.harper@bendigoit.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60322 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245Ab3CVLGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 07:06:02 -0400
Content-Disposition: inline
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B387FB199@BITCOM1.int.sbss.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:14:17PM +0000, James Harper wrote:
> > 
> >> Actually it turns out GPLPV just stops counting at 20. If I keep
> >> counting I can sometimes see over 1000 buffers per GSO packet under
> >> Windows using "iperf -
> > 
> > Do you think it is necessary to increase MAX_SKB_SLOTS_DEFAULT to 21?
> > 
> 
> Doesn't really matter. Under windows you have to coalesce anyway and the number of cases where the skb count is 20 or 21 is very small so there will be negligible gain and it will break guests that can't handle more than 19.

It's not about performance, it's about usability. If frontend uses more
slots than backend allows it to, it gets disconnected. In case we don't
push the wrong value upstream, it is important to know whether 20 is
enough for Windows PV driver.

> 
> Has anyone done the benchmarks on if memcpy to coalesce is better or worse than consuming additional ring slots? Probably OT here but I'm talking about packets that might have 19 buffers but could fit on a page or two of coalesced.
> 

After this changeset number of grant copy operations is greater or equal
to number of slots. I run iperf as my functional test, I also notice
the result is within the same range before this change.

And a future improvement would be using compound page for backend, which
can make number of grant copy ops more or less equal to number of slots
used.


Wei.

> James
> 
