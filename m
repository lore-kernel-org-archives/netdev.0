From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Thu, 09 Oct 2008 08:22:49 +0200
Message-ID: <48EDA339.3040706@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:55402 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756347AbYJIGWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 02:22:55 -0400
In-Reply-To: <20081009010957.GB6342@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 >>
 >> Simon, can you try to these things (separately):
 >> a/ increase quantum to the first class (say 10x)
 >
 > Hi Martin,
 >
 > Do you mean increase r2q ? If so, here are some results

no, no, add rather ... "quantum 50000" to the first class only
r2q affects computation for all classes

 >> b/ set ceil=rate on all three classes
 >
 > This seems pretty close to the expected/ideal result.
 >
 > 10194: 496575074bits/s 496Mbits/s
 > 10197:  96969861bits/s  96Mbits/s
 > 10196:  96973002bits/s  96Mbits/s
 > -----------------------------------
 > total: 690517938bits/s 690Mbits/s
 >

Hmm, it seems that problem is with drr loop or borrowing,
rate computation seems to work ok even in this corner case.

In any case from your other test follows that when NIC
throttles then HTB can't arrive at correct rates - I feel
this as HTB bug and add it to my (very long) todo list...

thanks, Martin
