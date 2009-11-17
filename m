From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH 2/2] ipv4: factorize cache clearing for batched unregister operations
Date: Mon, 16 Nov 2009 19:22:38 -0500
Message-ID: <20091117002238.GH12422@kvack.org>
References: <200911170149.50011.opurdila@ixiacom.com> <20091116160646.39c0a1ac@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:41382 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755215AbZKQAWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 19:22:33 -0500
Content-Disposition: inline
In-Reply-To: <20091116160646.39c0a1ac@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 04:06:46PM -0800, Stephen Hemminger wrote:
> And what about IPV6?

It's not possible to create more than a few thousand IPv6 interfaces in 
my tests with a 4GB vm.  The culprit seems to be the per-cpu arrays for 
statistics using vmalloc() and wasting gobs of memory as a result (memory 
usage seems to be 10x per interface vs what IPv4 is using), but I haven't 
dug too deeply yet.

		-ben
