From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 22:11:02 +1100
Message-ID: <20081009111100.GA28667@verge.net.au>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51747 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736AbYJILLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:11:05 -0400
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

Sorry, I wasn't aware of that parameter.
I ran a test now. With the default quantum (6250) for the 500Mbit/s
class I got:

10194: 383384949bits/s 383Mbits/s
10197: 285879669bits/s 285Mbits/s
10196: 287648424bits/s 287Mbits/s
-----------------------------------
total: 956913042bits/s 956Mbits/s

And when a quantum of 50000 for the 500Mbit/s class I got:

10194: 396345613bits/s 396Mbits/s
10197: 279511994bits/s 279Mbits/s
10196: 281062498bits/s 281Mbits/s
-----------------------------------
total: 956920106bits/s 956Mbits/s

> >> b/ set ceil=rate on all three classes
> >
> > This seems pretty close to the expected/ideal result.
> >
> > 10194: 496575074bits/s 496Mbits/s
> > 10197:  96969861bits/s  96Mbits/s
> > 10196:  96973002bits/s  96Mbits/s
> > -----------------------------------
> > total: 690517938bits/s 690Mbits/s
> >
>
> Hmm, it seems that problem is with drr loop or borrowing,
> rate computation seems to work ok even in this corner case.
>
> In any case from your other test follows that when NIC
> throttles then HTB can't arrive at correct rates - I feel
> this as HTB bug and add it to my (very long) todo list...
>
> thanks, Martin

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

