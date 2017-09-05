From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 16:07:51 +0200
Message-ID: <20170905140750.GB7936@nanopsycho>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, xiyou.wangcong@gmail.com, jhs@mojatatu.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:36071 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdIEOHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 10:07:54 -0400
Received: by mail-wr0-f178.google.com with SMTP id p14so7144033wrg.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 07:07:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 05, 2017 at 02:48:21PM CEST, nikolay@cumulusnetworks.com wrote:
>Hi all,
>This RFC adds a new mode for clsact which designates a device's egress
>classifier as global per netns. The packets that are not classified for
>a particular device will be classified using the global classifier.
>We have needed a global classifier for some time now for various
>purposes and setting the single bridge or loopback/vrf device as the
>global classifier device is acceptable for us. Doing it this way avoids
>the act/cls device and queue dependencies.
>
>This is strictly an RFC patch just to show the intent, if we agree on
>the details the proposed patch will have support for both ingress and
>egress, and will be using a static key to avoid the fast path test when no
>global classifier has been configured.
>
>Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
>$ tc qdisc add dev lo clsact global
>$ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop
>
>the last filter will be global for all devices that don't have a
>specific egress_cl_list (i.e. have clsact configured).
>
>Any comments and thoughts would be greatly appreciated.

Did you see my shared blocks work? I believe that it should resolve your
usecase, in a generic way. You just have to bind the devices you need to
the shared block. Please see the RFC:

https://www.spinics.net/lists/netdev/msg444067.html
