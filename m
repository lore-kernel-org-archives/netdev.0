From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 09:56:00 +0000
Message-ID: <20081009095600.GB4159@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:45560 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbYJIJ4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:56:08 -0400
Received: by ug-out-1314.google.com with SMTP id k3so883047ugf.37
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 02:56:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EDA339.3040706@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 08:22:49AM +0200, Martin Devera wrote:
> >>
> >> Simon, can you try to these things (separately):
> >> a/ increase quantum to the first class (say 10x)
> >
> > Hi Martin,
> >
> > Do you mean increase r2q ? If so, here are some results
>
> no, no, add rather ... "quantum 50000" to the first class only
> r2q affects computation for all classes

Yes, it's a half-documented parameter: not in the man, but e.g. here:
tc class add htb help

BTW, I wonder if better priority/quantum doesn't actually harm here.
When HTB lends the rate the first class here is always served at the
beginning. And if it's over the hardware limit, this class's packets
are waiting. Other classes get their chunks later, probably after the
card did some cleaning, so they may never have to wait at this
situation. So, maybe it would be interesting to try this other way:
lower priority of the first class with a prio param e.g. 1?

Jarek P.
