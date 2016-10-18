From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Mon, 17 Oct 2016 22:07:55 -0700
Message-ID: <5805AE2B.2040905@cumulusnetworks.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us> <1476276069-5315-5-git-send-email-jiri@resnulli.us> <58025A90.9010608@cumulusnetworks.com> <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com> <58056A08.5070809@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        Peter Phaal <peter.phaal@inmon.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32933 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755038AbcJRFH6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 01:07:58 -0400
Received: by mail-pf0-f170.google.com with SMTP id 128so88448735pfz.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 22:07:58 -0700 (PDT)
In-Reply-To: <58056A08.5070809@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/16, 5:17 PM, Roopa Prabhu wrote:
> On 10/17/16, 3:10 AM, Jamal Hadi Salim wrote:
[snip]

inline below more data/context..

>>>> +
>>>> +struct sample_packet_metadata {
>>>> +    int sample_size;
>>>> +    int orig_size;
>>>> +    int ifindex;
>>>> +};
>>>> +
>>> This metadata does not look extensible.. can it be made to ?
>>>
>> Sure it can...
more sflow context here... [1]

An extensible metadata scheme is  highly desirable when passing data from the dataplane to 
the sampling agent in userspace. Looking forward, advanced instrumentation is being 
added to data planes and keeping the api future proof will help.



>>
>>> With sflow in context, you need a pair of ifindex numbers to encode ingress and egress ports.
>> What is the use case for both?
> I have heard that most monitoring tools have moved to ingress only sampling because of operational
> complexity (use case is sflow). I think hardware also supports ingress and egress only sampling.
> better to have an option to reflect that in the api.

The reason for having two ifindex numbers is to record the ingress and egress ports (i.e. the path that the packet takes through the datapath/ASIC). You may actually have three ifindex numbers associated with a sample:
1. The data source that made the measurement (on a linux system each bridge has its own ifindex)
2. The ifindex associated with the ingress switch port
3. The ifindex associated with the egress switch port.

All three apply irrespective of sampling direction.


thanks,
Roopa

[1] Additional extended flow attributes have been defined to further extend sFlow packet samples:
http://sflow.org/sflow_tunnels.txt <http://sflow.org/sflow_tunnels.txt>
http://sflow.org/sflow_openflow.txt <http://sflow.org/sflow_openflow.txt>
