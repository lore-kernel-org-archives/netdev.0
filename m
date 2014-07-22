From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 19:12:02 -0400
Message-ID: <CAEP_g=9f2TFMU84qVUfzbPpjk3C8W3yzcYrA1MZr=528KVRfgQ@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
 <1406024393-6778-3-git-send-email-azhou@nicira.com> <CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
 <CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
 <CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
 <CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com> <CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:33417 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757135AbaGVXMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 19:12:30 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so491350qgf.17
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 16:12:22 -0700 (PDT)
In-Reply-To: <CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 6:38 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Jul 22, 2014 at 2:56 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Tue, Jul 22, 2014 at 5:16 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Tue, Jul 22, 2014 at 2:02 PM, Andy Zhou <azhou@nicira.com> wrote:
>>>> On Tue, Jul 22, 2014 at 12:52 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>> --- a/include/net/udp_tunnel.h
>>>>>> +++ b/include/net/udp_tunnel.h
>>>>>> @@ -1,7 +1,10 @@
>>>>>>  #ifndef __NET_UDP_TUNNEL_H
>>>>>>  #define __NET_UDP_TUNNEL_H
>>>>>>
>>>>>> -#define UDP_TUNNEL_TYPE_VXLAN 0x01
>>>>>> +#include <net/ip_tunnels.h>
>>>>>> +
>>>>>> +#define UDP_TUNNEL_TYPE_VXLAN  0x01
>>>>>> +#define UDP_TUNNEL_TYPE_GENEVE 0x02
>>>>>>
>>>>> Why do we need to define these? Caller should know what type of port is
>>>>> being opened and provide appropriate encap_rcv.
>>>>
>>>> Assume udp tunnel layer needs to keep track of open ports, should it
>>>> also keep track of the protocol associated with the port?
>>>>
>>> For what purpose? Other than for offloads and rcv_encap functions that
>>> provide the service function anyway, what need is there for UDP layer
>>> to know about this. More to the point, if I add a module to the kernel
>>> with a new flavor of UDP tunneling, I shouldn't have to touch any core
>>> code for things to work correctly. So by this line of thinking,
>>> neither the terms VXLAN nor GENEVE should appear in any common code.
>>
>> The hardware will need to know what the header format is so that it
>> can parse the packets on receive. And since the NIC can't exactly call
>> into a function pointer like GRO can, I'm not sure that there is a
>> solution that doesn't involve an identifier that needs to be listed
>> somewhere. This is a pretty minimal impact - it doesn't actually
>> appear in the core code.
>
> The hardware doesn't *need* to know this, it's must be optional and
> should have no bearing on the software stack. Suggest to put them in
> their own header file. Also, as HW features these should appear in
> NETIF_F_* list so that we can control on a per device level rather to
> enable this feature (something like how NETIF_F_GSO_* was done).

Right - I meant for hardware offload. Obviously, pure software
implementations should continue to work fine with the tunnel stack (as
it does here). I don't have any particular objection to moving them to
a different file (udp_offload.h?) but I agree with Alex that these are
slightly different than hardware feature flags.

> What about support for L2TP/UDP?

It should be possible to take advantage of the common UDP tunnel code
here as well. I believe that Andy is planning on doing it as a follow
up patch, which would be a good example of a pure software
implementation.
