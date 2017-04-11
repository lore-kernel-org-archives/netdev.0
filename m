From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 09:02:52 +0200
Message-ID: <1491894172.31620.2.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         <20170408202434.12018-2-johannes@sipsolutions.net>
         <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
         <1491838218.28432.5.camel@sipsolutions.net>
         <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
         <20170411065908.GB1492@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47398 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752359AbdDKHCz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 03:02:55 -0400
In-Reply-To: <20170411065908.GB1492@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 08:59 +0200, Pablo Neira Ayuso wrote:
> CAP_ACK means: trim off the payload that the netlink error message
> is embedding, just like ICMP error does.
> 
> What is exactly your concern? If the user explicitly requests this
> via socket option for this socket, then we're expecting they do the
> right handling for what they're asking for.

I think David's concern was that when you want to parse the ACK in a
library (or application), you may not easily know if the application
(or library) requested capping.

I've addressed this by adding two new flags now, though the CAPPED flag
can only be relied on when the TLVS flag is present, but that's the
only case where you care anyway. I felt that we had enough space to
spend two bits rather than one, in order to not have to rely on any
length calculations to see if TLVs are present - as I'd suggested in my
email last night.

johannes
