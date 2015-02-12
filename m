From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Thu, 12 Feb 2015 08:21:58 -0800
Message-ID: <1423758118.4942.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150212005844.GB3829@nwwn.com>
	 <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150212052428.GB10785@eden.sea.cyngn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Marshall <tom@cyngn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:58921 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857AbbBLQWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 11:22:04 -0500
Received: by mail-wi0-f173.google.com with SMTP id bs8so5601821wib.0
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 08:22:02 -0800 (PST)
In-Reply-To: <20150212052428.GB10785@eden.sea.cyngn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-11 at 21:24 -0800, Tom Marshall wrote:
> On Wed, Feb 11, 2015 at 08:06:14PM -0800, Eric Dumazet wrote:
> > On Wed, 2015-02-11 at 16:58 -0800, Tom Marshall wrote:
> > > Port zero is reserved according to IANA.
> > > 
> > > Note UDP sendto is already disallowed if dport is zero.
> > 
> > I have no idea why we should prevent such thing.
> 
> * It is marked "reserved" by IANA.
> 
> * UDP packets with dport=0 are already prevented from being sent.
> 
> * Many routers will either drop the packets or, worse, send back a RST to a
>   SYN destined for port 0.

Some networking/supervision applications might use this knowledge to
send TCP probes with dport=0, expecting to get an RST, knowing no
listener could possibly answer with a SYNACK.

If you take a look at traceroute -p TCP, you'll be shocked that it sends
malformed TCP packets. IANA never complained about this, so far.
