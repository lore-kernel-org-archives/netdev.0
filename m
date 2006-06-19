From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [RFT] pcnet32 NAPI changes
Date: Mon, 19 Jun 2006 10:58:36 -0400
Message-ID: <20060619145836.GF26952@csclub.uwaterloo.ca>
References: <20060616191154.GA6227@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:63141 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S932453AbWFSO6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 10:58:37 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060616191154.GA6227@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2006 at 12:11:54PM -0700, Don Fry wrote:
> This patch is a collection of changes to pcnet32 which does the
> following: 
> 
> - Fix section mismatch warning.
> - fix set_ringparam to correctly handle memory allocation failures
> - fix off-by-one in get_ringparam.
> - cleanup at end of loopback_test when not up.
> - Add NAPI to driver, fixing set_ringparam and loopback_test to work
>   correctly with poll.
> - for multicast, do not reset the chip unless cannot enter suspend mode
>   to avoid race with poll.
> 
> The set_ringparam code is larger than I would prefer, but it will not
> leave null pointers around for the code to stumble over when memory
> allocation fails.  If anyone has a better idea, please let me know.
> 
> Some complexity could be avoided by allocating memory for the maximum
> number of tx and rx buffers at probe time.  Requiring 14k for the tx
> ring and arrays, and another 14k for rx; instead of about 10k total for
> the default sizes.

So 28k vs 10k?  Why are these adjustable if it makes that little
difference?  Is there any advantage to making them smaller?

> It is NAPI only, unlike Len Sorensen's version which allows for compile
> time selection.  Some drivers are NAPI only, others have compile
> options.  Which is preferred?

I just figured making it an option was less intrusive, although I can't
imagine a good reason for not wanting to use the NAPI version at all
times.  I certainly know I intend to use it that way.

> I have tested these changes with a 79C971, 973, 976, and 978 on a ppc64
> machine, and 970A, 972, 973, 975, and 976 on an x86 machine.
> 
> I have not tested these changes with VMware or Xen.

I will give it a try with our system and see how it runs.

Len Sorensen
