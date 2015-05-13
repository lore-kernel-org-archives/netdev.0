From: Joe Perches <joe@perches.com>
Subject: Re: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Wed, 13 May 2015 10:34:51 -0700
Message-ID: <1431538491.2912.14.camel@perches.com>
References: <1431456145.2884.75.camel@perches.com>
	 <20150513131908.GB8431@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0251.hostedemail.com ([216.40.44.251]:39778 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752521AbbEMRey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 13:34:54 -0400
In-Reply-To: <20150513131908.GB8431@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 16:19 +0300, Dan Carpenter wrote:
> Good eye, Joe.
> 
> I wrote a Smatch check to find similar bugs.  Te rhey weren't any other
> places which tried to do bitwise OR.  The bug that happens occasionally
> is:
> 
> #define MY_FLAG BIT(1)
> 
> 	if (test_bit(MY_FLAG, &map)) {
> 		...
> 
> It's not normally harmful if it's used consistently, but ath9k had
> memory corruption because they do:
> 
> 	set_bit(BIT(6), &some_unsigned_long);
> 
> Anyway, I'll send patches for the bugs I found and push the Smatch
> check. Thanks!

In case the patches you found weren't of this type,
there are other possibly suspicious uses with & like:

drivers/usb/host/ehci-tegra.c:		set_bit((wIndex & 0xff) - 1, &ehci->suspended_ports);
