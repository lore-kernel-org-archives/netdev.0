From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] bridge: remove !IFF_UP restriction when deleting
 bridge from ioctl
Date: Fri, 4 Apr 2014 10:23:57 -0700
Message-ID: <20140404102357.353fbb08@nehalam.linuxnetplumber.net>
References: <1396623382.15118.6.camel@dcbw.local>
	<20140404.110800.1665495271585798396.davem@davemloft.net>
	<1396624550.15118.11.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:52595 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbaDDRYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 13:24:01 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so3606391pdi.2
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 10:24:01 -0700 (PDT)
In-Reply-To: <1396624550.15118.11.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Apr 2014 10:15:50 -0500
Dan Williams <dcbw@redhat.com> wrote:

> On Fri, 2014-04-04 at 11:08 -0400, David Miller wrote:
> > From: Dan Williams <dcbw@redhat.com>
> > Date: Fri, 04 Apr 2014 09:56:22 -0500
> > 
> > > netlink doesn't care about IFF_UP when deleting a bridge, so "ip link
> > > del br0" works just fine.  The ioctl does care, which means that brctl
> > > complains "bridge br0 still up; can't delete it".  Make things
> > > consistent by always allowing bridge deletion even if the bridge is up.
> > > 
> > > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > > ---
> > > Question: does anyone consider the ioctl behavior API?  Can we change it
> > > even though it's been this way forever?  It means that bridges that
> > > previously would not have been deleted by brctl will now be deleted.
> > > But anyone using /sbin/ip could already delete them.
> > 
> > Unfortunately I think we're stuck with the existing behavior.
> 
> Ok, fair enough.
> 
> Dan
> 
> 

That is the way it has been all the way back to 2.4.
