From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than 10 times.
Date: Tue, 29 Jun 2010 09:03:49 +0100
Message-ID: <50mof7-b9p.ln1@chipmunk.wormnet.eu>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60400 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896Ab0F2IaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 04:30:04 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OTWCh-000771-Rz
	for netdev@vger.kernel.org; Tue, 29 Jun 2010 10:30:03 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 10:30:03 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 10:30:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

greearb@gmail.com wrote:
> 
> The default remains at 10 for backwards compatibility.
> 
> For instance:
> # ip addr flush dev eth2
> *** Flush remains incomplete after 10 rounds. ***
> # ip -l 20 addr flush dev eth2
> *** Flush remains incomplete after 20 rounds. ***
> # ip -loops 0 addr flush dev eth2
> #
> 
> This is useful for getting rid of large numbers of IP
> addresses in scripts.
> 
Maybe I am missing a trick, but what is wrong with putting this trivial 
logic into the script:

ip addr show ${DEV} | awk '/inet6? / { print $2 }' | xargs -I{} ip addr del '{}' dev ${DEV}

You can probably speed things up with '-P' too, '-P 2' gives me a huge 
huge speed up for the work I do with 'ip route'.

If you still have addresses on your interface after the above command, 
your looping approach probably would have failed also.

Why the need to cram more functionality and options into iproute when 
it is something that can be pushed into the wrapper script? 

Cheers

-- 
Alexander Clouter
.sigmonster says: Lend money to a bad debtor and he will hate you.

