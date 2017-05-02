From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 12:39:51 -0600
Message-ID: <3acddce9-5421-637e-8b2b-ae8dd5c7b29a@cumulusnetworks.com>
References: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
 <20170502082531.43b32e05@xeon-e3>
 <7fa44ec5-9a3a-55d1-b058-540d37ef01bd@cumulusnetworks.com>
 <20170502.130032.1854491688518080191.davem@davemloft.net>
 <20170502110314.66d9ee89@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com
To: Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33615 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751224AbdEBSjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 14:39:53 -0400
Received: by mail-pf0-f180.google.com with SMTP id q20so1225207pfg.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:39:53 -0700 (PDT)
In-Reply-To: <20170502110314.66d9ee89@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/17 12:03 PM, Stephen Hemminger wrote:
> Then use libmnl it is already used in several other places in iproute2.
> Eventually, I would like to use it everywhere and get rid of old netlink parser.
> 

Why? libmnl is not going to simplify the iproute2 code.

Look at attribute validation. Importing the kernel code into iproute2,
the API is very familiar to anyone hacking on the kernel side:

+       if (nla_parse(tb, NLMSGERR_ATTR_MAX, attr, alen, extack_policy)
!= 0) {
+               fprintf(stderr,
+                       "Failed to parse extended error attributes\n");
+               return 0;
+       }
+

ie., you pass a policy to the parse routine and the checking is part of
nla_parse. The implementation of nla_parse and validate_nla are quite
easy to read.

Now take a look at what devlink has for validation - attr_cb. IMO very
unreadable and puts the burden on the app using the libmnl API.
