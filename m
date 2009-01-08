From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Thu, 8 Jan 2009 11:04:30 +0000
Message-ID: <20090108110430.GB5493@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <20090108094231.GD4496@ff.dom.local> <20090108095403.GE4496@ff.dom.local> <20090108100614.GA5418@ff.dom.local> <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:64887 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbZAHLEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 06:04:37 -0500
Received: by ewy12 with SMTP id 12so3107710ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 03:04:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 10:35:39AM -0000, mysql.jorge@decimal.pt wrote:
> Well, even with that, why it works perfectly when i use the 100Mbit NIC?
> There must be something here that needs an ajustment, no?

It's hard to tell because these two things (cbq and tbf) use different
methods, which could interact strange way (and are not expected to work
together). I think you should test them alone first (especially tbf),
and send here the tc comannd plus "tc -s qdisc show dev eth0" and
"tc -s class show dev eth0" output while traffic is run. You could also
add this "ethtool -k eth0" and "ifconfig eth0".

Jarek P. 


> >>
> >> Hmm... Actually, it's probably about config: I'm not cbq user or
> >> expert, but AFAIK it depends on precise info about the real link
> >> rate, so it probably needs an update to 1000Mbit.
> >
> > Hmm#2... I missed this tbf thing: this could point to GSO again, but
> > generally it's considered as a bug to use more than one non-work-
> > conserving qdisc in a tree (so e.g. cbq with any of tbf/htb/hfsc
> > together).
> >
> > Jarek P.
> >
> 
> 
