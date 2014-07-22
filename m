From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 14:02:36 -0700
Message-ID: <CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-3-git-send-email-azhou@nicira.com>
	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog003.obsmtp.com ([74.125.150.46]:51814 "HELO
	na6sys009bog003.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932128AbaGVVJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:09:31 -0400
Received: by mail-oa0-f51.google.com with SMTP id o6so367659oag.24
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:09:30 -0700 (PDT)
In-Reply-To: <CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 12:52 PM, Tom Herbert <therbert@google.com> wrote:
>
>
> On Tue, Jul 22, 2014 at 3:19 AM, Andy Zhou <azhou@nicira.com> wrote:
>> Added create_udp_tunnel_socket(), packet receive and transmit,  and
>> other related common functions for UDP tunnels.
>>
>> Per net open UDP tunnel ports are tracked in this common layer to
>> prevent sharing of a single port with more than one UDP tunnel.
>>
> bind should already prevent this. I don't really see a need to track udp
> encap ports separately.

When a new network device driver is activated, does it need to get a list
of currently open UDP tunnel ports to configure its offloads?

>> --- a/include/net/udp_tunnel.h
>> +++ b/include/net/udp_tunnel.h
>> @@ -1,7 +1,10 @@
>>  #ifndef __NET_UDP_TUNNEL_H
>>  #define __NET_UDP_TUNNEL_H
>>
>> -#define UDP_TUNNEL_TYPE_VXLAN 0x01
>> +#include <net/ip_tunnels.h>
>> +
>> +#define UDP_TUNNEL_TYPE_VXLAN  0x01
>> +#define UDP_TUNNEL_TYPE_GENEVE 0x02
>>
> Why do we need to define these? Caller should know what type of port is
> being opened and provide appropriate encap_rcv.

Assume udp tunnel layer needs to keep track of open ports, should it
also keep track of the protocol associated with the port?

>> +
>> +/* Calls the ndo_add_tunnel_port of the caller in order to
>> + * supply the listening VXLAN udp ports. Callers are expected
>> + * to implement the ndo_add_tunnle_port.
>> + */
> Seems a little presumptuous that we're doing VXLAN specific things in what
> should be common and generic code...
>
You are right. Cut-and-past error. It should read "UDP tunnel ports"
instead. I will fix it.
