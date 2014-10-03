From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 6/6] openvswitch: Add support for Geneve tunneling.
Date: Thu, 2 Oct 2014 18:48:45 -0700
Message-ID: <CAEP_g=_Q_HR=fA1qo=RzB8CkV78CzRO6-w6LV12HVrQLYL9Tgw@mail.gmail.com>
References: <1412237085-27215-1-git-send-email-azhou@nicira.com>
 <1412237085-27215-7-git-send-email-azhou@nicira.com> <CA+mtBx_gswubpaBF1bX-dRN580Xv2F5aJAJaKRp56pFeWzRWEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:36648 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752458AbaJCBtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 21:49:07 -0400
Received: by mail-qc0-f177.google.com with SMTP id c9so308982qcz.8
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 18:49:05 -0700 (PDT)
In-Reply-To: <CA+mtBx_gswubpaBF1bX-dRN580Xv2F5aJAJaKRp56pFeWzRWEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 2, 2014 at 4:04 PM, Tom Herbert <therbert@google.com> wrote:
> On Thu, Oct 2, 2014 at 1:04 AM, Andy Zhou <azhou@nicira.com> wrote:
>> From: Jesse Gross <jesse@nicira.com>
>>
>> The Openvswitch implementation is completely agnostic to the options
>> that are in use and can handle newly defined options without
>> further work. It does this by simply matching on a byte array
>> of options and allowing userspace to setup flows on this array.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  include/net/ip_tunnels.h         |   21 ++--
>>  include/uapi/linux/openvswitch.h |    2 +
>>  net/openvswitch/Kconfig          |   11 ++
>>  net/openvswitch/Makefile         |    4 +
>>  net/openvswitch/datapath.c       |    5 +-
>>  net/openvswitch/flow.c           |   20 +++-
>>  net/openvswitch/flow.h           |   20 +++-
>>  net/openvswitch/flow_netlink.c   |  176 +++++++++++++++++++++++-----
>>  net/openvswitch/vport-geneve.c   |  236 ++++++++++++++++++++++++++++++++++++++
>>  net/openvswitch/vport-gre.c      |    2 +-
>>  net/openvswitch/vport-vxlan.c    |    2 +-
>>  net/openvswitch/vport.c          |    3 +
>>  net/openvswitch/vport.h          |    1 +
>>  13 files changed, 461 insertions(+), 42 deletions(-)
>>  create mode 100644 net/openvswitch/vport-geneve.c
>>
>> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
>> index a9ce155..5bc6ede 100644
>> --- a/include/net/ip_tunnels.h
>> +++ b/include/net/ip_tunnels.h
>> @@ -86,17 +86,18 @@ struct ip_tunnel {
>>         struct gro_cells        gro_cells;
>>  };
>>
>> -#define TUNNEL_CSUM    __cpu_to_be16(0x01)
>> -#define TUNNEL_ROUTING __cpu_to_be16(0x02)
>> -#define TUNNEL_KEY     __cpu_to_be16(0x04)
>> -#define TUNNEL_SEQ     __cpu_to_be16(0x08)
>> -#define TUNNEL_STRICT  __cpu_to_be16(0x10)
>> -#define TUNNEL_REC     __cpu_to_be16(0x20)
>> -#define TUNNEL_VERSION __cpu_to_be16(0x40)
>> -#define TUNNEL_NO_KEY  __cpu_to_be16(0x80)
>> +#define TUNNEL_CSUM            __cpu_to_be16(0x01)
>> +#define TUNNEL_ROUTING         __cpu_to_be16(0x02)
>> +#define TUNNEL_KEY             __cpu_to_be16(0x04)
>> +#define TUNNEL_SEQ             __cpu_to_be16(0x08)
>> +#define TUNNEL_STRICT          __cpu_to_be16(0x10)
>> +#define TUNNEL_REC             __cpu_to_be16(0x20)
>
> Just changing whitespace in these?

Yeah, it's just reindenting to match the new values.
