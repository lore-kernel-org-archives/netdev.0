From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Wed, 13 May 2015 16:19:08 +0300
Message-ID: <20150513131908.GB8431@mwanda>
References: <1431456145.2884.75.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26835 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbbEMNTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:19:20 -0400
Content-Disposition: inline
In-Reply-To: <1431456145.2884.75.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good eye, Joe.

I wrote a Smatch check to find similar bugs.  They weren't any other
places which tried to do bitwise OR.  The bug that happens occasionally
is:

#define MY_FLAG BIT(1)

	if (test_bit(MY_FLAG, &map)) {
		...

It's not normally harmful if it's used consistently, but ath9k had
memory corruption because they do:

	set_bit(BIT(6), &some_unsigned_long);

Anyway, I'll send patches for the bugs I found and push the Smatch
check. Thanks!

regards,
dan carpenter
