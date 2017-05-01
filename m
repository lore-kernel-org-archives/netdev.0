From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next iproute2] ip: increase number of MPLS labels
Date: Mon, 1 May 2017 15:22:06 -0600
Message-ID: <70667d3a-5cbc-4900-3c41-bce508a057ac@cumulusnetworks.com>
References: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
 <20170429230430.702c6b72@xeon-e3>
 <ddb54ca8-d7df-3446-3929-5f0116286c80@cumulusnetworks.com>
 <20170501091540.13f57676@xeon-e3> <8737convca.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34455 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdEAVWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 17:22:09 -0400
Received: by mail-pf0-f177.google.com with SMTP id e64so42004850pfd.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 14:22:08 -0700 (PDT)
In-Reply-To: <8737convca.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/17 3:03 PM, Eric W. Biederman wrote:
> Basically the kernel maximum is how large we can make struct mpls_route
> without while being < 4096 aka PAGE_SIZE.  Which also happens to be
> larger than the largest known consumer.

2 limits in the kernel:
1. max allocation for mpls_route of 4096
2. max number of labels of 30.

The latter was necessitated by the LWT path. I wanted a cap on it and
for the cap to be consistent for both ingress and LSP. To that end I
went with a maximum of 30 labels in the kernel: 4k max allocation = ~30
labels per nexthop with ~30 nexthops. For both 30 is excessive, overkill
number. (though someone did ask me recently why not 512 labels. seriously)

I can't say it makes sense for iproute2 to support 30 labels.
Argumentative that even 16 is too high, but some folks have argued for it.


> Dave is there a practical reason that is motivating increasing the size
> in iproute?  Or is the desire to ensure that iproute can take full
> advantage of the kernel?

I suspect only routing daemons would inject a high label stack. It would
be nice for iproute2 to 1. be able to print that route properly
(currently does not if the label count exceeds what it can handle), 2.
be able to reinject the route. Even with scripting creating a route
using ip with a lot of labels is a PITA.
