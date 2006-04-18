From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH][RFC] Security marking
Date: Mon, 17 Apr 2006 21:01:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604172051510.20174@d.namei>
References: <20060417184053.6D618378FD@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, fireflier-devel@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:2743 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932078AbWDRBBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 21:01:09 -0400
To: edwin@gurde.com
In-Reply-To: <20060417184053.6D618378FD@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006, edwin@gurde.com wrote:

> Secmark, or skfilter is exactly what fireflier needs to solve the shared 
> socket issue. Thanks for working on this. If this gets integrated in 
> mainline, fireflier LSM will be dropped.

I think you probably need skfilter as a standalone option.

> Is it possible to have an SELinux policy that reinjects the packets if didn't match any rules?
> I.e. if a program that listens on port 80 doesn't have access to the packet, (because it doesn't have the proper domain,)
> and the SELinux won't allow the program to read the packet: is it possible to reinject this packet in the netfilter chain,
> instead of dropping it?
> 
> This would allow creating rules interactively (fireflier). 

This could be done with nfqueue, modular policy and a pretty simple tool.  

Although, nfqueue doesn't work at the socket layer (but perhaps would with 
skfilter).

> What does the secmark currently do with packets that aren't allowed by policy to be received?

Under SELinux, they'd be silently dropped.

> P.S.: Where can I get the full secmark patches, so I can test them to see if they really fit my needs?
> Do you have an estimate timeline for mainline integration? (in terms of n weeks, m months)

The rest of the secmark related patches don't exist yet, I posted the core 
changes needed, and the others will be SELinux-specific.  Mainline 
integration would hopefully be 2.6.18, if it all works out ok.


If you're looking for skfilter:
http://people.redhat.com/jmorris/selinux/skfilter/

Patrick McHardy has some ideas on resolving some of the skfilter issues.


- James
-- 
James Morris
<jmorris@namei.org>
