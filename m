From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 00:09:44 -0700 (PDT)
Message-ID: <20080426.000944.50852302.davem@davemloft.net>
References: <20080425.223130.04936392.davem@davemloft.net>
	<OF7B59958D.88AA9A1D-ON88257437.0023AEDC-88257437.00268638@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752112AbYDZHJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 03:09:45 -0400
In-Reply-To: <OF7B59958D.88AA9A1D-ON88257437.0023AEDC-88257437.00268638@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Sat, 26 Apr 2008 00:00:49 -0700

>         I did see that plain old structure field __attribute((4))__
> wasn't correct (still padded), and gcc docs use the same language
> to define the behavior for structure field attribute "aligned" and
> type attribute "aligned" (at least with my limited research). So,
> it surprised me that the field attribute results in pad and the
> type attribute doesn't, and I wonder if it's good to rely on that
> difference given the same documentation for both as "minimum alignment".
> But if the compiler changes its notion of when to pad this in a way
> that breaks it, we can always revisit it later. :-)

You're right about this point of course:

--------------------
struct foo {
	int a;
	unsigned long b;
};

struct foo_align4 {
	int a;
	unsigned long b;
} __attribute__((aligned(4)));

int main(void)
{
	printf("Normal: 'b' offset is %Zu\n",
	       __builtin_offsetof(struct foo, b));
	printf("Align4: 'b' offset is %Zu\n",
	       __builtin_offsetof(struct foo_align4, b));
	return 0;
}
--------------------

gives:

--------------------
Normal: 'b' offset is 8
Align4: 'b' offset is 8
--------------------

on sparc64.

So if we need to use packed because of that specific problem here,
fine.
