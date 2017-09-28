From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Thu, 28 Sep 2017 11:28:38 -0700
Message-ID: <CAOrHB_CQyokdTWeoj02RENPP5miq5Arx6goCNQ9ZPbUeTu_MeQ@mail.gmail.com>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925201439.08460295@griffin> <20170926045538.GA5896@localhost.localdomain>
 <20170926124914.60101ca1@griffin> <20170927013908.GA33716@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Benc <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Jan Scheurich <jan.scheurich@ericsson.com>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:34088 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdI1S2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 14:28:40 -0400
Received: from mail-wr0-f181.google.com (mail-wr0-f181.google.com [209.85.128.181])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id A7EB51720A4
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 20:28:39 +0200 (CEST)
Received: by mail-wr0-f181.google.com with SMTP id b21so4253490wrg.7
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 11:28:39 -0700 (PDT)
In-Reply-To: <20170927013908.GA33716@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 6:39 PM, Yang, Yi <yi.y.yang@intel.com> wrote:
> On Tue, Sep 26, 2017 at 06:49:14PM +0800, Jiri Benc wrote:
>> On Tue, 26 Sep 2017 12:55:39 +0800, Yang, Yi wrote:
>> > After push_nsh, the packet won't be recirculated to flow pipeline, so
>> > key->eth.type must be set explicitly here, but for pop_nsh, the packet
>> > will be recirculated to flow pipeline, it will be reparsed, so
>> > key->eth.type will be set in packet parse function, we needn't handle it
>> > in pop_nsh.
>>
>> This seems to be a very different approach than what we currently have.
>> Looking at the code, the requirement after "destructive" actions such
>> as pushing or popping headers is to recirculate.
>
> This is optimization proposed by Jan Scheurich, recurculating after push_nsh
> will impact on performance, recurculating after pop_nsh is unavoidable, So
> also cc jan.scheurich@ericsson.com.
>
> Actucally all the keys before push_nsh are still there after push_nsh,
> push_nsh has updated all the nsh keys, so recirculating remains avoidable.
>


We should keep existing model for this patch. Later you can submit
optimization patch with specific use cases and performance
improvement. So that we can evaluate code complexity and benefits.

>>
>> Setting key->eth.type to satisfy conditions in the output path without
>> updating the rest of the key looks very hacky and fragile to me. There
>> might be other conditions and dependencies that are not obvious.
>> I don't think the code was written with such code path in mind.
>>
>> I'd like to hear what Pravin thinks about this.
>>
>>  Jiri
