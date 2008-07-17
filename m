From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 06:31:54 -0400
Message-ID: <1216290714.4638.49.camel@localhost>
References: <20080716220058.GA31425@amd64.fatal.se>
	 <20080716150320.63f20215@extreme>
	 <1216247237.31646.12.camel@amd64.fatal.se>
	 <20080716152631.04125f56@extreme> <1216247722.3422.38.camel@johannes.berg>
	 <20080716155354.28281053@extreme>
	 <1216254660.31646.54.camel@amd64.fatal.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	489340@bugs.debian.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:20742 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbYGQKb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:31:58 -0400
Received: by wr-out-0506.google.com with SMTP id 69so4418776wri.5
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 03:31:57 -0700 (PDT)
In-Reply-To: <1216254660.31646.54.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-07 at 02:31 +0200, Andreas Henriksson wrote:

> Why? 

Thats just how it rolls.

> This seems like a really bad idea to me, and none of the callers in
> iproute benefits from this as far as I can see.

The receiver(kernel in this case, but it could be some other user space
user) returning a zero means success. Essentially zero is an (Positive)
ACK.
The receiver returning a non-zero implies a failure. Essentially a
N(egative) ACK. 

In the case of a NACK, the kernel must return you the original message
header you sent (similar to the way some icmp messages behave).
The returned error code is a standard errno - if you sent a bad config
you may get an EINVAL back. The sender combines the errno + the header
to figure out what went wrong.

Does that make sense? So the kernel fix is required (as Stephen noted).

cheers,
jamal

