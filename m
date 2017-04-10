From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 0/5] netlink extended ACK reporting
Date: Mon, 10 Apr 2017 13:20:42 +0200
Message-ID: <1491823242.2455.9.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         (sfid-20170408_222447_224133_39B19566)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us,
        David Miller <davem@davemloft.net>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36206 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdDJLUt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 07:20:49 -0400
In-Reply-To: <20170408202434.12018-1-johannes@sipsolutions.net> (sfid-20170408_222447_224133_39B19566)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I thought a little bit more about the part of reporting the broken and
missing attributes, and I'm not sure I'm entirely happy with that part.

For reporting broken attributes, I think the pointer is really the best
thing we can do - adding the attribute number in addition to that would
seem to be easy to misuse in userspace, and there's no information
about nesting at that point and the "malformed attribute" ID will not
make any sense without knowing the nesting level. So I think we
shouldn't add the attribute ID there. The userspace app can disentangle
the nesting, or it can know that it never used nesting, for example.

Similarly, the "missing attribute" ID - which I did add an attribute
for but didn't use it yet - can result in similar interpretation
problems. I'm not really sure what to do with this one - technically
one could report back the entire nesting chain, but having that kind of
state might be really difficult.

Did anyone already have any plans for the "missing attribute"
functionality?


And another thought regarding the strict checking: we might also want
to extend that to strictly check the *size* of attributes as well. For
example, right now, if the kernel wants a u8 attribute but userspace
uses a u16 or u32, this will work on little-endian and be accepted but
wrongly be 0 on big endian.

johannes
