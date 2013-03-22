From: James Harper <james.harper@bendigoit.com.au>
Subject: RE: [Xen-devel] [PATCH 4/4] xen-netback: coalesce slots before
 copying
Date: Fri, 22 Mar 2013 11:19:56 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B387FD91E@BITCOM1.int.sbss.com.au>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
 <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
 <6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
 <6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
 <CAOsiSVWSRmo1+Ubo7GyAKcvUr8XUenkMvnAqt607gPoJm-sXFQ@mail.gmail.com>
 <6035A0D088A63A46850C3988ED045A4B387FB199@BITCOM1.int.sbss.com.au>
 <20130322110600.GA5742@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <liuw@liuw.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bendigoit.com.au ([203.16.207.99]:43509 "EHLO
	smtp2.bendigoit.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932460Ab3CVLUJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 07:20:09 -0400
In-Reply-To: <20130322110600.GA5742@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> On Thu, Mar 21, 2013 at 10:14:17PM +0000, James Harper wrote:
> > >
> > >> Actually it turns out GPLPV just stops counting at 20. If I keep
> > >> counting I can sometimes see over 1000 buffers per GSO packet under
> > >> Windows using "iperf -
> > >
> > > Do you think it is necessary to increase MAX_SKB_SLOTS_DEFAULT to 21?
> > >
> >
> > Doesn't really matter. Under windows you have to coalesce anyway and
> the number of cases where the skb count is 20 or 21 is very small so there will
> be negligible gain and it will break guests that can't handle more than 19.
> 
> It's not about performance, it's about usability. If frontend uses more
> slots than backend allows it to, it gets disconnected. In case we don't
> push the wrong value upstream, it is important to know whether 20 is
> enough for Windows PV driver.
> 

Windows will accept whatever you throw at it (there may be some upper limit, but I suspect it's quite high). Whatever Linux will accept, it will be less than the 1000+ buffers that Windows can generate, so some degree of coalescing will be required for Windows->Linux.

In GPLPV I already coalesce anything with more than 19 buffers, because I have no guarantee that Dom0 will accept anything more (and who knows what Solaris or BSD will accept, if those are still valid backends...), so whatever you increase Dom0 to won't matter because I would still need to assume that Linux can't accept more than 19, until such time as Dom0 (or driver domain) advertises the maximum buffer count it can support in xenstore...

So do what you need to do to make Linux work, just don't put the erroneous comment that "windows has a maximum of 20 buffers" or whatever it was in the comments :)

James
