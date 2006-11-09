From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Thu, 9 Nov 2006 01:15:10 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0611090109120.10907@d.namei>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com> <4552A9AC.3060708@hp.com>
 <Pine.LNX.4.64.0611082337520.5916@d.namei> <4552B5C1.8040007@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:59619 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1753599AbWKIGPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:15:14 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <4552B5C1.8040007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006, Paul Moore wrote:

> James Morris wrote:
> > On Wed, 8 Nov 2006, Paul Moore wrote:
> > 
> >>1. Functionality is available right now, no additional kernel changes needed
> >>2. No special handling for localhost, I tend to like the idea of having
> >>consistent behavior for all addresses/interfaces
> > 
> > I don't agree.  SO_PEERSEC should always just work for loopback, just like 
> > with Unix sockets.
> 
> My main concern is that we would have "special" behavior for a single IP address
>    and that this behavior wouldn't be subject to the same labeled networking
> configuration/management methods as the rest of the address space.

It's a very special case, and loopack networking has lots of special case 
handling because of this.  It's nearly zero cost to have this work, and 
then you get full SELinux control over local IP communications.

It doesn't prevent the IPsec stuff from working, if you want it to 
override the default.  But would people really run IPsec for localhost 
communications?

Let's keep the simple case simple.

>  Treating localhost like any other IP address seems consistent with the 
> way we handle Unix sockets - we don't have any special handling 
> depending on the path of the socket.

Unix sockets can't do both local and remote communication.


- James
-- 
James Morris
<jmorris@namei.org>
