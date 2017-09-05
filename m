From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 21:25:47 +0300
Message-ID: <36e9c09d-8598-1cee-1436-82e0ef7d75fb@cumulusnetworks.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:34320 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdIESZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:25:50 -0400
Received: by mail-wr0-f172.google.com with SMTP id a47so8550802wra.1
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 11:25:50 -0700 (PDT)
In-Reply-To: <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/17 9:18 PM, Cong Wang wrote:
> On Tue, Sep 5, 2017 at 5:48 AM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> Hi all,
>> This RFC adds a new mode for clsact which designates a device's egress
>> classifier as global per netns. The packets that are not classified for
>> a particular device will be classified using the global classifier.
>> We have needed a global classifier for some time now for various
>> purposes and setting the single bridge or loopback/vrf device as the
>> global classifier device is acceptable for us. Doing it this way avoids
>> the act/cls device and queue dependencies.
>>
>> This is strictly an RFC patch just to show the intent, if we agree on
>> the details the proposed patch will have support for both ingress and
>> egress, and will be using a static key to avoid the fast path test when no
>> global classifier has been configured.
>>
>> Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
>> $ tc qdisc add dev lo clsact global
>> $ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop
>>
>> the last filter will be global for all devices that don't have a
>> specific egress_cl_list (i.e. have clsact configured).
> 
> Sorry this is too ugly
> 
> netdevice is still implied in your command line even if you treat it
> as global. It is essentially hard to bypass netdevice layer since
> netdevice is the core of L2 and also where everything begins.
> 

This is only a quick RFC, that can be removed entirely if we limit it to the 
netns and its loopback device. Then we can drop the "device" keyword altogether.

> Maybe the best we can do here is make tc filters standalone
> as tc actions so that filters can exist before qdisc's and netdevices.
> But this probably requires significant works to make it working
> with both existing non-standalone and bindings standalones
> with qdisc's.
>

We've actually been discussing this option internally as well.
I think we'll look into doing that regardless of this patch.
> Note I don't look deeply into this, just one thought, at least this
> appears less ugly than yours.
> 

What I did was aimed at simplicity and is merely a mode of clsact which
doesn't have an impact if not configured. Every other solution requires
a much more invasive change, note that doesn't mean I don't agree. :-)
