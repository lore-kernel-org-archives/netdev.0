From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: 3.6.10 tcp crash - net/ipv4/tcp.c:1667 & tcp.c:1655
Date: Mon, 17 Dec 2012 14:52:13 -0500
Message-ID: <20121217195212.GI22452@kvack.org>
References: <20121217174145.GH22452@kvack.org> <1355772853.9380.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:58525 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab2LQTwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 14:52:14 -0500
Content-Disposition: inline
In-Reply-To: <1355772853.9380.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 11:34:13AM -0800, Eric Dumazet wrote:
> On Mon, 2012-12-17 at 12:41 -0500, Benjamin LaHaise wrote:
> > Hi folks,
> > 
> > I just hit the following crash with Fedora's 3.6.10-2.fc17 kernel.  I don't 
> > have time to debug this myself at the moment, but can certainly test patches 
> > or provide more info as needed.  I wasn't doing anything unusual at the time, 
> > just reading email/web browsing.  I believe the network driver in use was 
> > ipheth for tethering to an iPhone 4S over USB (the other driver being used 
> > intermittently on this laptop is iwlwifi).  Any ideas?
> 
> I see nothing really wrong on ipheth side.
> 
> I would be nice to know which driver is really in use when you have a
> panic, as its probably a driver issue.

I double checked the logs, and the wifi was disabled at the time (~30 
minutes beforehand), so it had to be ipheth.  The warnings were the last 
thing that made it to disk before the machine hung hard, so there may have 
been a more serious crash after the warning that did not get logged.

One thing I have observed with tethering is that the MTU handling is munged 
by the network in interesting ways.  Although the device claims to be 
ethernet with a 1500 byte MTU, a 'ping -s' works only up to 996 (with no 
effect trying the various -M options).  A number of website are broken by 
this, as the network doesn't seem to send ICMP frag needed errors to my 
tethered host (but I haven't traced this behaviour from both ends yet).  
Things do work for 1500 byte packets to the gateway IP, but that seems 
to be local to the phone.

		-ben
-- 
"Thought is the essence of where you are now."
