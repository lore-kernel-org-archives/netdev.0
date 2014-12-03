From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip link: Show devices by link type
Date: Wed, 3 Dec 2014 17:08:18 +0200
Message-ID: <CAMw6YJKDn0oEthe8FxhRkAnPwQzKJR2OrOQ3rvnMq9vqz-40sw@mail.gmail.com>
References: <1417370335-15772-1-git-send-email-vadim4j@gmail.com>
	<547E5F90.2060105@cumulusnetworks.com>
	<20141203011305.GA5945@angus-think.lan>
	<547F20CA.4060501@cumulusnetworks.com>
	<CAMw6YJKxPK_MKbCdxVwGSBXbZ7MqtXBA3FJ_ovw4-8heB6ci9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:62759 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaLCPIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 10:08:20 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so20029644wgh.11
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 07:08:19 -0800 (PST)
In-Reply-To: <CAMw6YJKxPK_MKbCdxVwGSBXbZ7MqtXBA3FJ_ovw4-8heB6ci9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have sent v2 with subject "ip link: Show devices by type"

Regards,
Vadim

On Wed, Dec 3, 2014 at 4:47 PM, Vadim Kochan <vadim4j@gmail.com> wrote:
> OK, I can use it)
>
> Thanks,
>
> On Wed, Dec 3, 2014 at 4:40 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 12/2/14, 5:13 PM, vadim4j@gmail.com wrote:
>>>
>>> On Tue, Dec 02, 2014 at 04:55:44PM -0800, Roopa Prabhu wrote:
>>>>>
>>>>>         int master;
>>>>> +       char *link_kind;
>>>>
>>>> The name can be just "kind", given all the others dont use the link
>>>> prefix
>>>>>
>>>>>   } filter;
>>>
>>> OK
>>>
>>>>> +       if (filter.link_kind && tb[IFLA_LINKINFO]) {
>>>>> +               char *link_kind = parse_link_kind(tb[IFLA_LINKINFO]);
>>>>> +               if (strcmp(link_kind, filter.link_kind)) {
>>>>> +                       return -1;
>>>>> +               }
>>>>
>>>> you can skip the braces
>>>>>
>>>>> +       } else if (filter.link_kind)
>>>>
>>>> you have if (filter.link_kind) twice, you can use a single if without the
>>>> else.
>>>>>
>>>>> +               return -1;
>>>>> +
>>>
>>> I need to skip interfaces which has not IFLA_LINKINFO attribute,
>>> w/o "else if(...)" I get bridges with normal ether devices:
>>>           bash# ip link show type bridge
>>>
>>>      1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
>>> mode DEFAULT group default
>>>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>>      2: enp0s25: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc
>>> pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>>>          link/ether XX:XX:XX:XX:XX:XX brd ff:ff:ff:ff:ff:ff
>>>      5: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
>>> DEFAULT group default
>>>          link/ether 6e:02:f9:17:7f:10 brd ff:ff:ff:ff:ff:ff
>>>
>>> but expected result should be only bridges.
>>
>>
>> I was just saying, it could be:
>>
>> if (filter.link_kind) {
>>     if (tb[IFLA_LINKINFO]) {
>>         char *kind = parse_link_kind(tb[IFLA_LINKINFO]);
>>         if (strcmp(kind, filter.kind))
>>             return -1;
>>     } else {
>>       return -1;
>>     }
>> }
