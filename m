From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 21:43:29 +0200
Message-ID: <1491939809.27324.1.camel@sipsolutions.net>
References: <1491894172.31620.2.camel@sipsolutions.net>
         <9a68aa01-474c-7054-30c2-473ee1250abe@cumulusnetworks.com>
         <20170411173143.GA1899@salvia>
         <20170411.134225.398046538225438175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, jhs@mojatatu.com, jbenc@redhat.com,
        jiri@resnulli.us
To: David Miller <davem@davemloft.net>, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54270 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752753AbdDKTng (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 15:43:36 -0400
In-Reply-To: <20170411.134225.398046538225438175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 13:42 -0400, David Miller wrote:

> > Then, the library needs to be extended to enable this handling to
> > modify the way it needs to handle errors, together with the
> > setsockopt().

So I'd tend to agree, but

 * it was easy to solve this, with the flags I added
 * the flags reduce the amount of parsing dependencies, for example, it
   is then no longer necessary to check if error == 0 to know if the
   message was capped or not (when not requested), since the flag
   indicates it
 * having the flag that TLVs were set lets us not store if the
   setsockopt failed or not - this can be useful in the error report
   case (but not in the success/cookie case) since it avoids extra
   state that needs to be passed around
 * libnl, which seems pretty common, allows just passing a single
   pointer around as state, which is often already used for something
   else, meaning a bigger refactoring can be required to pass the extra
   state

So yes, in theory we don't need this, but in practice it does make the
userland parsing code quite a bit easier.

johannes
