From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 08:17:01 -0700
Message-ID: <CAJieiUgsHBCXB2F9tp7pNYLjDAApqH-5eHReef6dQAc5WY=+9Q@mail.gmail.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com> <20170905140750.GB7936@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35928 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdIEPRC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 11:17:02 -0400
Received: by mail-pg0-f49.google.com with SMTP id m9so10023531pgd.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 08:17:02 -0700 (PDT)
In-Reply-To: <20170905140750.GB7936@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 7:07 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Sep 05, 2017 at 02:48:21PM CEST, nikolay@cumulusnetworks.com wrote:
>>Hi all,
>>This RFC adds a new mode for clsact which designates a device's egress
>>classifier as global per netns. The packets that are not classified for
>>a particular device will be classified using the global classifier.
>>We have needed a global classifier for some time now for various
>>purposes and setting the single bridge or loopback/vrf device as the
>>global classifier device is acceptable for us. Doing it this way avoids
>>the act/cls device and queue dependencies.
>>
>>This is strictly an RFC patch just to show the intent, if we agree on
>>the details the proposed patch will have support for both ingress and
>>egress, and will be using a static key to avoid the fast path test when no
>>global classifier has been configured.
>>
>>Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
>>$ tc qdisc add dev lo clsact global
>>$ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop
>>
>>the last filter will be global for all devices that don't have a
>>specific egress_cl_list (i.e. have clsact configured).
>>
>>Any comments and thoughts would be greatly appreciated.
>
> Did you see my shared blocks work? I believe that it should resolve your
> usecase, in a generic way. You just have to bind the devices you need to
> the shared block. Please see the RFC:
>
> https://www.spinics.net/lists/netdev/msg444067.html


Jiri, yes, we have seen this series. This still requires one to make
the association between dev and tc shared block..and
the rules are associated with every device. Your work will help the
case and is needed for tc in general and can co-exist.
It takes us closer but is still not a way to create global tc rules.
imagine thousands of netdevs. We would ideally like the show to also
display a single set of rules.
Given tc has a rich set of classifiers and actions (and very
extensible!), we are trying to see if those can
be easily applied globally than being tied to a device. Maybe there
are other better ways to achieve this...this thread
is to start that discussion. I think solving this once will help the
scale issue for your hardware offload case as well.
