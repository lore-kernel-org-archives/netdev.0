From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] sky2 vs iptables
Date: Thu, 21 Sep 2006 16:37:37 -0700
Message-ID: <20060921163737.027b7701@dxpl.pdx.osdl.net>
References: <44FE2618.3010705@gentoo.org>
	<20060906141651.116aa758@localhost.localdomain>
	<450CBA9A.4040705@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45205 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932115AbWIUXhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 19:37:47 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <450CBA9A.4040705@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Sep 2006 23:01:46 -0400
Daniel Drake <dsd@gentoo.org> wrote:

> Stephen Hemminger wrote:
> > On Tue, 05 Sep 2006 21:36:24 -0400
> > Daniel Drake <dsd@gentoo.org> wrote:
> >> There's a strange sky2 bug on the Gentoo bugzilla:
> >> http://bugs.gentoo.org/show_bug.cgi?id=136508
> >>
> >> sky2 seems to work OK, but breaks as soon as the iptables ruleset is 
> >> loaded. Nothing can be pinged, etc.
> >>
> >> Can someone try and reproduce this? The iptables rule script has been 
> >> uploaded here:
> >> http://bugs.gentoo.org/attachment.cgi?id=95694&action=view
> >>
> >> The very last command in that file is the one which produces an error 
> >> and stops everything working:
> >>
> >> 	iptables: Unknown error 18446744073709551615
> >>
> >> Apparently a sky2 null deref has also been seen at this point, although 
> >> I don't have further details on that.
> > 
> > It might be an artifact of the way sky2 was allocating receive buffers.
> > Bridge-netfilter was assuming header space in the buffer, and would corrupt
> > other memory, maybe iptables is assuming as well. This makes sky2
> > use dev_alloc_skb that reserves space.
> > -----------------------
> > Subject: sky2: use dev_alloc_skb for receive buffers
> 
> Unfortunately the problem still exists with this patch. Any other ideas?
> 
> Daniel

I tried the script with 2.6.18 and saw no problem.
Of course, my configuration was probably different and I wasn't
running Gentoo.   Eth0 was a sky2 device, and eth1 was a skge.
