From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Sat, 14 Oct 2017 13:52:32 +0300
Message-ID: <ad6cc6a9-326e-df49-6945-0b010ed07cb2@cumulusnetworks.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
 <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
 <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
 <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
 <85d15rvxze.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:43621 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751818AbdJNKwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 06:52:35 -0400
Received: by mail-wm0-f49.google.com with SMTP id m72so30687803wmc.0
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 03:52:34 -0700 (PDT)
In-Reply-To: <85d15rvxze.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/10/17 19:00, Roman Mashak wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:
> 
> 
> [...]
> 
>>>> Why do you want to return the error code here? Walking the code paths
>>>> seems like ENOENT or err from switchdev_port_obj_del are the 2 error
>>>> possibilities.
>>>
>>> For example, if you attempt to delete a non-existing vlan on a port,
>>> the current code succeeds and also sends event :
>>>
>>> rtnetlink_rcv_msg
>>>     rtnl_bridge_dellink
>>>        br_dellink
>>>           br_afspec
>>>              br_vlan_info
>>>
>>> int br_dellink(..)
>>> {
>>>   ...
>>>   err = br_afspec()
>>>   if (err == 0)
>>>       br_ifinfo_notify(RTM_NEWLINK, p);
>>> }
>>>
>>> This is misleading, so a proper errcode has to be produced.
>>>
>>
>> True, but you also change the expected behaviour because now a user can
>> clear all vlans with one request (1 - 4094), and after the change that
>> will fail with a partial delete if some vlan was missing.
> 
> Nikolay, would you like to have a crack at fixing this?
> 

Sure, need to finish something and will cook up a patch next week.

Thanks,
 Nik
