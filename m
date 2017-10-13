From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting Vlan
Date: Fri, 13 Oct 2017 12:00:53 -0400
Message-ID: <85d15rvxze.fsf@mojatatu.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
        <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
        <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
        <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:44738 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdJMQA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 12:00:59 -0400
Received: by mail-io0-f179.google.com with SMTP id m16so9484319iod.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 09:00:59 -0700 (PDT)
In-Reply-To: <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
        (Nikolay Aleksandrov's message of "Thu, 12 Oct 2017 21:12:31 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:


[...]

>>> Why do you want to return the error code here? Walking the code paths
>>> seems like ENOENT or err from switchdev_port_obj_del are the 2 error
>>> possibilities.
>> 
>> For example, if you attempt to delete a non-existing vlan on a port,
>> the current code succeeds and also sends event :
>> 
>> rtnetlink_rcv_msg
>>     rtnl_bridge_dellink
>>        br_dellink
>>           br_afspec
>>              br_vlan_info
>> 
>> int br_dellink(..)
>> {
>>   ...
>>   err = br_afspec()
>>   if (err == 0)
>>       br_ifinfo_notify(RTM_NEWLINK, p);
>> }
>> 
>> This is misleading, so a proper errcode has to be produced.
>> 
>
> True, but you also change the expected behaviour because now a user can
> clear all vlans with one request (1 - 4094), and after the change that
> will fail with a partial delete if some vlan was missing.

Nikolay, would you like to have a crack at fixing this?

> This has been the behaviour forever and some script might depend on it.
> Also IMO, and as David also mentioned, doing a partial delete is not good.
