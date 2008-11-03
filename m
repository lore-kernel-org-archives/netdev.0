From: "Sangtae Ha" <sangtae.ha@gmail.com>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Mon, 3 Nov 2008 17:19:52 -0500
Message-ID: <649aecc70811031419o78e9046eu52adf78eef8da7d7@mail.gmail.com>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	 <20081102.002736.193701976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:1722 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbYKCWTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 17:19:53 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1329782qwe.37
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 14:19:52 -0800 (PST)
In-Reply-To: <20081102.002736.193701976.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We had rather extensive testings with one MacOSX receiver of the
latest Leopard release.
As we had one macbook pro available in the lab, all the testing
results are with the one receiver.
Based on the tested results, MacOSX also doesn't break the algorithm.

Please see the results at the following:

http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing#Testing_with_MacOSX

One thing I observed with FreeBSD and MacOS receivers is that
even though we set the large send and recv buffer and run the iperf
with the large fixed memory,
without manually setting the window scale parameter to a higher value,
the receiver window is limited to 64K << 3 (which is the default of MacOSX).

Because of that, I had to set the window scailing parameter from 3 to
13 manually.
This also affects SACK not triggering with the default window scale factor of 3.
Linux certainly doesn't have this problem.

Probably, MacOSX and FreeBSD may need some updates for this issue.

Thank you for all your feedbacks,

Sangtae



On Sun, Nov 2, 2008 at 2:27 AM, David Miller <davem@davemloft.net> wrote:
> I'm applying this patch to net-next-2.6 for three reasons:
>
> 1) it is easily the cleanest and most well done CUBIC patch submission,
>   and they should be rewarded for the quality of this work
>
> 2) the only way to get exposure is to merge this now and look out for
>   problems, and yes that means keeping it the default
>
> 3) if there is a problem it's a one line change to revert to previous
>   CUBIC behvaior, by setting hystart to 0, and that's always a safe
>   alternative because that is pretty much what is deployed all over
>   the world right now
>
