From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 11:29:59 +0000
Message-ID: <20130326112959.GF7004@zion.uk.xensource.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
 <5150699C.6080209@citrix.com>
 <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
 <51507C9B.3080109@citrix.com>
 <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
 <51509789.8090608@citrix.com>
 <20130325190911.GC7004@zion.uk.xensource.com>
 <515182E2.50103@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <liuw@liuw.name>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6570 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792Ab3CZLaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 07:30:01 -0400
Content-Disposition: inline
In-Reply-To: <515182E2.50103@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 11:13:38AM +0000, David Vrabel wrote:
> >>
> >> Separately, it may be sensible for the backend to drop packets with more
> >> frags than max-slots-per-frame up to some threshold where anything more
> >> is considered malicious (i.e., 1 - 18 slots is a valid packet, 19-20 are
> >> dropped and 21 or more is a fatal error).
> >>
> > 
> > Why drop the packet when we are able to process it? Frontend cannot know
> > it has crossed the line anyway.
> 
> Because it's a change to the protocol and we do not want to do this for
> a regression fix.
> 

If I understand correctly the regression you talked about was introduced
by harsh punishment in XSA-39? If so, this is the patch you need to fix
that. Frontend only knows that it has connectivity or not. This patch
guarantee that the old netfront with larger MAX_SKB_FRAGS still see the
same thing from its point of view.  Netfront cannot know the
intermediate state between 18 and 20.

> As a separate fix we can consider increasing the number of slots
> per-packet once there is a mechanism to report this to the front end.
> 

Sure, that's on my TODO list.


Wei.
