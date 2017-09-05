From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 11:18:14 -0700
Message-ID: <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34002 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752327AbdIESSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:18:35 -0400
Received: by mail-pf0-f195.google.com with SMTP id y68so2002833pfd.1
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 11:18:35 -0700 (PDT)
In-Reply-To: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 5:48 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> Hi all,
> This RFC adds a new mode for clsact which designates a device's egress
> classifier as global per netns. The packets that are not classified for
> a particular device will be classified using the global classifier.
> We have needed a global classifier for some time now for various
> purposes and setting the single bridge or loopback/vrf device as the
> global classifier device is acceptable for us. Doing it this way avoids
> the act/cls device and queue dependencies.
>
> This is strictly an RFC patch just to show the intent, if we agree on
> the details the proposed patch will have support for both ingress and
> egress, and will be using a static key to avoid the fast path test when no
> global classifier has been configured.
>
> Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
> $ tc qdisc add dev lo clsact global
> $ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop
>
> the last filter will be global for all devices that don't have a
> specific egress_cl_list (i.e. have clsact configured).

Sorry this is too ugly.

netdevice is still implied in your command line even if you treat it
as global. It is essentially hard to bypass netdevice layer since
netdevice is the core of L2 and also where everything begins.

Maybe the best we can do here is make tc filters standalone
as tc actions so that filters can exist before qdisc's and netdevices.
But this probably requires significant works to make it working
with both existing non-standalone and bindings standalones
with qdisc's.

Note I don't look deeply into this, just one thought, at least this
appears less ugly than yours.
