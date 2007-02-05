From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Mon, 5 Feb 2007 12:24:53 +0100
Message-ID: <200702051224.53777.ak@suse.de>
References: <20070205101637.GB1863@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Lodal <simonl@parknet.dk>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:41968 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101AbXBELZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 06:25:01 -0500
In-Reply-To: <20070205101637.GB1863@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 11:16, Jarek Poplawski wrote:

> 
> Strange - it seems you gave only arguments against this
> analysis...

For a naturally clustered key space (as is common in this case) the two 
level structure is likely more cache efficient than a generic hash function. 
That is because the hash will likely spread out the natural clusters and then require
more cache lines to access them because there will be less sharing.

Ok in theory a very tuned for this case hash function might have similar 
properties, but normally people don't put that much care into 
designing hashes and just use some generic one.

> > And the worst memory consumption case considered by Patrick should
> > be relatively unlikely.
> 
> Anyway, such approach, that most users do something
> this (reasonable) way, doesn't look like good
> programming practice.

In the unlikely worst case they will get half a MB of tables. Hardly a 
show stopper. 

> I wonder, why not try, at least for a while, to do this
> a compile (menuconfig) option with a comment:
> recommended for a large number of classes. After hash
> optimization and some testing, final decisions could be
> made.

There are already far too many obscure CONFIGs. Don't add more.

-Andi
 
