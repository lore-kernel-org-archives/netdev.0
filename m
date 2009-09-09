From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 9 Sep 2009 13:55:43 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
 <4AA7E082.90807@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:57181 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752393AbZIIR4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 13:56:48 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2005082C399
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 13:57:48 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YwHOifsjEDaP for <netdev@vger.kernel.org>;
	Wed,  9 Sep 2009 13:57:42 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3B4E582C39F
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 13:57:42 -0400 (EDT)
In-Reply-To: <4AA7E082.90807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2009, Eric Dumazet wrote:

> > My loopback numbers also show the same trends.
> >
> > 2.6.22:
> >
> > mcast -Ln1
> > TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
> >      101      0      0      0      10     3.0    5.47    5.74    7.00  0.43
> >
> > 2.6.31-rc9
> >
> > mcast -Ln1
> > TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
> >      100      0      0      0      10     3.0   13.26   13.45   13.56  0.09
> >
> >
> > So 2.6.22 is better at 10 msgs per second. 2.6.31 is slightly better at
> > 10k.
>
> Linux nag001 2.6.26-2-amd64 #1 SMP Fri Mar 27 04:02:59 UTC 2009 x86_64 GNU/Linux
>
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
>      101      0      0      0      10     3.0    8.42    9.47   11.53  0.85
>
> Also I believe you hit scheduler artefact at very low rate,
> since there are two tasks that are considered as coupled.
>
> Check commit 6f3d09291b4982991680b61763b2541e53e2a95f

Reverting that patch yields:

clameter@rd-strategy3-deb64:~$ ./mcast -Ln1

TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
     101      0      0      0      10     3.0   27.21   31.28   52.68  8.16

Not good.

