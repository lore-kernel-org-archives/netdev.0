From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-next v4 0/5] netlink extended ACK reporting
Date: Tue, 11 Apr 2017 08:56:55 +0200
Message-ID: <20170411065700.2623-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47278 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752335AbdDKG5I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 02:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v3:
 * Add NLM_F_CAPPED and NLM_F_ACK_TLVS flags, to allow entirely
   stateless parsing of the ACK messages by looking at the new
   flags. Need to check NLM_F_ACK_TLVS first, since capping can
   be done in kernels before this patchset without setting the
   flag.
 * Remove "missing_attr" functionality - this can obviously be
   added back rather easily, but I'd rather have more discussion
   about the nesting problem there.
 * Improve documentation of NLMSGERR_ATTR_OFFS
 * Improve message structure documentation, documenting that the
   request message is always capped for success cases
 * fix nlmsg_len of the outer message by calling nlmsg_end()
 * fix memcpy() of the request in success cases, going back to
   the original code that I'd changed before due to the payload
   adjustments that I reverted when introducing tlvlen

Big thanks to David Ahern for the feedback from changing iproute2!

Patch for iw demonstrating the stateless parsing is here:
https://p.sipsolutions.net/93ae7ea3afbba8d6.txt

johannes
