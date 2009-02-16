From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [BUG] SNAT sometimes allows packets to pass through unchanged
Date: Mon, 16 Feb 2009 11:41:50 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0902161134070.15521-100000@netrider.rowland.org>
References: <49999393.3040105@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:1623 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751728AbZBPQlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 11:41:51 -0500
In-Reply-To: <49999393.3040105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Feb 2009, Patrick McHardy wrote:

> Alan Stern wrote:
> > On Mon, 16 Feb 2009, Patrick McHardy wrote:
> > 
> >>> I tried adding a rule to log these unaccounted-for packets.  Nothing 
> >>> showed up, even when I could see the packets being sent.
> >> Where (table/chain/position) did you add this rule?
> > 
> > In the first position of the POSTROUTING chain in the nat table.  I
> > don't remember exactly what rules I used, but at one point I tried
> > something very much like this:
> > 
> > iptables -t nat -I POSTROUTING 1 -s 10.0.0.0/8 -p tcp ! --syn
> > 
> > The counter for this rule remained at 0 even after packets with private 
> > source addresses were sent through the public interface.
> 
> The NAT table only sees the first packet of every connection
> and never INVALID packets. The mangle table should work fine.

Okay, I'll try it instead.  Are these facts documented anywhere?  FWIW, 
I don't recall ever seeing anywhere a description of what packets go 
through the mangle table, or at what stage of processing.

> You can also enable conntrack-internal logging of invalid packets:
> 
> echo 255 >/proc/sys/net/netfilter/nf_conntrack_log_invalid

I did this (except I used the value of IPPROTO_TCP instead of 255).  
Several things did get logged, but no messages were produced for the
packets I'm concerned about.  _That_ definitely seemed like a bug...

> > I tried using 2 6.27 kernel but the problem remained.  Building a later 
> > version won't be easy because of the need to create the proper config.  
> > Can you remember in which version these bugs got fixed?
> 
> Sorry, no.

Hm.  Maybe I'll try to set up a test system with a 2.6.29-rc kernel, to 
see if the problem really has been fixed yet.

Alan Stern

