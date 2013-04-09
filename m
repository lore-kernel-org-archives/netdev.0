From: Ed W <lists@wildgooses.com>
Subject: Modifying the exponential backoff on new connection SYN packets
Date: Tue, 09 Apr 2013 10:06:17 +0100
Message-ID: <5163DA09.5070202@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.nippynetworks.com ([91.220.24.129]:34597 "EHLO
	mail1.nippynetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935178Ab3DIJQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 05:16:15 -0400
Received: from localhost (mail1.nippynetworks.com [127.0.0.1])
	by mail1.nippynetworks.com (Postfix) with ESMTP id DDF70340398
	for <netdev@vger.kernel.org>; Tue,  9 Apr 2013 10:06:17 +0100 (BST)
Received: from mail1.nippynetworks.com ([127.0.0.1])
	by localhost (mail1.nippynetworks.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id arot2ifXvDxO for <netdev@vger.kernel.org>;
	Tue,  9 Apr 2013 10:06:17 +0100 (BST)
Received: from eds-macbook-pro.nippynetworks.local (unknown [212.69.38.73])
	(Authenticated sender: edward@wildgooses.com)
	by mail1.nippynetworks.com (Postfix) with ESMTPSA id 8B302340373
	for <netdev@vger.kernel.org>; Tue,  9 Apr 2013 10:06:17 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I have an unusual situation in that I would like to cap the 
retransmit frequency on the initial SYN packets at some fairly short 
time interval, eg a max of 2-4 seconds, rather than the usual 
exponentially increasing interval.  I could use some help figuring out 
the exact point in the kernel to make such a change please?

The situation is that I am building a firewall which will be used with 
expensive satellite links (think $10-100/MB range). Some of the links 
are dialup links which take 20-40 seconds to bring up, and then we have 
PPP drop the link after 10 seconds of inactivity. However, with the 
default exponential backoff on new connections we are generally 
retransmitting with a 16sec or 32 sec interval by the time the dialup 
link is connected, the timout for inactivity kicks in and drops the link 
before the retransmit...

I believe the exponential backoff is intended to prevent amplification 
attacks? In this particular case we are accounting for traffic per user 
and the internet costs are extremely substantial, so I think it's not a 
problem

Could someone please help figure out the appropriate place to tweak the 
exponential backoff? Note this is not retransmit of in flight data, just 
the backoff for the initial syn (which doesn't seem to be configurable 
in user space?)

Note, we have an application proxy here, but I can't see a sensible way 
to fake it in user space without a lot of extra coding - any suggestions?

Thanks

Ed W
