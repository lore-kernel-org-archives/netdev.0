From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 20:38:46 +0200
Message-ID: <1491849526.28432.10.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         <20170408202434.12018-2-johannes@sipsolutions.net>
         <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
         <1491838218.28432.5.camel@sipsolutions.net>
         <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
         (sfid-20170410_173530_723869_8DC854E1) <1491838811.28432.8.camel@sipsolutions.net>
         (sfid-20170410_174029_427546_31B89496)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: David Ahern <dsa@cumulusnetworks.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40990 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752124AbdDJSiu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 14:38:50 -0400
In-Reply-To: <1491838811.28432.8.camel@sipsolutions.net> (sfid-20170410_174029_427546_31B89496)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-10 at 17:40 +0200, Johannes Berg wrote:
> 
> Another thought: if we add a new flag that indicates "message has
> been capped", which we introduce in this same patch, then we can
> disentangle this more easily, right?
> 
> Adding a new flag for "TLVs present" won't really help, but if you
> know the message was capped then you know the TLVs start after the
> inner nlmsghdr and you ignore that header's nlmsg_len.

Actually, the flag should be set if (and only if) the message was
capped *and* TLVs were requested (or present, doesn't matter.)

That way it becomes completely backward compatible and stateless:
 * on kernels that don't have extack you can ignore the setsockopt
   failure
 * checking if TLVs are present becomes
   flag set ||
   nlh->nlmsg_len > sizeof(*nlh) + sizeof(int) +
                    sizeof(*inner_nlh) + inner_nlh->nlmsg_len
 * TLV start offset is
   tlv_start_offs = sizeof(*nlh) + sizeof(int) + sizeof(inner_nlh)
   if (flag set)
       tlv_start_offs += inner_nlh->nlmsg_len

I need to resend anyway so I'll add that tomorrow.

johannes
