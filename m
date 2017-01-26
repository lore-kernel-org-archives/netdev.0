From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 16:32:21 +0100
Message-ID: <1485444741.14760.12.camel@sipsolutions.net>
References: <1485437276.14760.3.camel@sipsolutions.net>
         <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_144502_343976_16232A6D) <1485438546.14760.7.camel@sipsolutions.net>
         <1485441942.5145.131.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_154545_190303_B1FB80BF) <1485442164.14760.11.camel@sipsolutions.net>
         <1485444276.5145.133.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_162439_678922_DB33D27A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50760 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753399AbdAZPc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:32:26 -0500
In-Reply-To: <1485444276.5145.133.camel@edumazet-glaptop3.roam.corp.google.com> (sfid-20170126_162439_678922_DB33D27A)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 07:24 -0800, Eric Dumazet wrote:
> On Thu, 2017-01-26 at 15:49 +0100, Johannes Berg wrote:
> 
> > Unfortunately, I haven't been able to actually test this yet. I
> > also
> > didn't find the code that would drop frames with CSUM 0 either, so
> > I'm
> > thinking - for now - that if all the csum handling is skipped,
> > dropping
> > 0 csum frames would also be, and then we'd accept a frame we should
> > actually have dropped.
> > 
> > I'll go test this I guess :)
> > 
> > Any pointers to where 0 csum frames are dropped?
> 
> Probably in udp6_csum_init()

Well, now that I see that, I see that they're actually valid in some
circumstances. Oops. :)

Will need to revisit, and check how we set no_check6_rx, etc.

johannes
