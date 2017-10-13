From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Thu, 12 Oct 2017 22:03:30 -0400
Message-ID: <64292550-f043-c1f7-5b0e-004288832887@mojatatu.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
 <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
 <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
 <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Roman Mashak <mrv@mojatatu.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:47293 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753326AbdJMCDd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 22:03:33 -0400
Received: by mail-it0-f43.google.com with SMTP id p138so9565808itp.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 19:03:33 -0700 (PDT)
In-Reply-To: <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-12 02:12 PM, Nikolay Aleksandrov wrote:
> On 12/10/17 21:07, Roman Mashak wrote:

>> For example, if you attempt to delete a non-existing vlan on a port,
>> the current code succeeds and also sends event :
>>
>> rtnetlink_rcv_msg
>>      rtnl_bridge_dellink
>>         br_dellink
>>            br_afspec
>>               br_vlan_info
>>
>> int br_dellink(..)
>> {
>>    ...
>>    err = br_afspec()
>>    if (err == 0)
>>        br_ifinfo_notify(RTM_NEWLINK, p);
>> }
>>
>> This is misleading, so a proper errcode has to be produced.
>>
>



> True, but you also change the expected behaviour because now a user can
> clear all vlans with one request (1 - 4094), and after the change that
> will fail with a partial delete if some vlan was missing.
> 

The issue is more subtle (per Roman above):
Try to delete a vlan (that doesnt  exist).
1) It says "success".
2) Worse: Another process listening (bridge monitor?) gets an _event_
  that  the vlan has been deleted (when it never existed in the first
  place).

> This has been the behaviour forever and some script might depend on it.
> Also IMO, and as David also mentioned, doing a partial delete is not good.
>

I think this is a bug (especially the event part).

cheers,
jamal
