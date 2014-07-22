From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 15:38:29 -0700
Message-ID: <CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-3-git-send-email-azhou@nicira.com>
	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
	<CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
	<CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
	<CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:56520 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbaGVWia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:38:30 -0400
Received: by mail-ie0-f176.google.com with SMTP id tr6so291922ieb.21
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 15:38:30 -0700 (PDT)
In-Reply-To: <CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 2:56 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Tue, Jul 22, 2014 at 5:16 PM, Tom Herbert <therbert@google.com> wrote:
>> On Tue, Jul 22, 2014 at 2:02 PM, Andy Zhou <azhou@nicira.com> wrote:
>>> On Tue, Jul 22, 2014 at 12:52 PM, Tom Herbert <therbert@google.com> wrote:
>>>>> --- a/include/net/udp_tunnel.h
>>>>> +++ b/include/net/udp_tunnel.h
>>>>> @@ -1,7 +1,10 @@
>>>>>  #ifndef __NET_UDP_TUNNEL_H
>>>>>  #define __NET_UDP_TUNNEL_H
>>>>>
>>>>> -#define UDP_TUNNEL_TYPE_VXLAN 0x01
>>>>> +#include <net/ip_tunnels.h>
>>>>> +
>>>>> +#define UDP_TUNNEL_TYPE_VXLAN  0x01
>>>>> +#define UDP_TUNNEL_TYPE_GENEVE 0x02
>>>>>
>>>> Why do we need to define these? Caller should know what type of port is
>>>> being opened and provide appropriate encap_rcv.
>>>
>>> Assume udp tunnel layer needs to keep track of open ports, should it
>>> also keep track of the protocol associated with the port?
>>>
>> For what purpose? Other than for offloads and rcv_encap functions that
>> provide the service function anyway, what need is there for UDP layer
>> to know about this. More to the point, if I add a module to the kernel
>> with a new flavor of UDP tunneling, I shouldn't have to touch any core
>> code for things to work correctly. So by this line of thinking,
>> neither the terms VXLAN nor GENEVE should appear in any common code.
>
> The hardware will need to know what the header format is so that it
> can parse the packets on receive. And since the NIC can't exactly call
> into a function pointer like GRO can, I'm not sure that there is a
> solution that doesn't involve an identifier that needs to be listed
> somewhere. This is a pretty minimal impact - it doesn't actually
> appear in the core code.

The hardware doesn't *need* to know this, it's must be optional and
should have no bearing on the software stack. Suggest to put them in
their own header file. Also, as HW features these should appear in
NETIF_F_* list so that we can control on a per device level rather to
enable this feature (something like how NETIF_F_GSO_* was done).

What about support for L2TP/UDP?
