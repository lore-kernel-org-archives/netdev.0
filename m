From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netconsole still hangs
Date: Thu, 13 Mar 2008 00:59:01 -0700
Message-ID: <20080313005901.fdc2c67e.akpm@linux-foundation.org>
References: <20080312161637.b082b515.akpm@linux-foundation.org>
	<20080312163013.aaf07aa0.akpm@linux-foundation.org>
	<20080312165717.c0879b1d.akpm@linux-foundation.org>
	<20080312.231053.216645957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52457 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751259AbYCMH7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:59:52 -0400
In-Reply-To: <20080312.231053.216645957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 23:10:53 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 12 Mar 2008 16:57:17 -0700
> 
> > I reran the test on 2.6.24 and all seemed fine: the machine didn't hang and
> > stopping the script stopped the netconsole output.
> 
> Can you go back and bisect the tree in one shot to the guilty
> commit you found last time, and make sure this test case
> works at that point?

Plain old

git-checkout 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7 seems to dtrt.



git-checkout 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7

  Fails very very easily.  Basically the machine never successfully boots.


git-checkout 0953864160bdd28dfe45fd46fa462b4d2d53cb96

  Works OK.


So yes, I'd say that the revert was not complete.


aside: running that while loop just slays the machine.  It took 30 seocnds
to respond to ^C (across ssh over the same link).  There's some severe
starvation happening somewhere.

