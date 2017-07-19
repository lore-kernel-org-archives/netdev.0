From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 14/17] mlxsw: spectrum_router: Add support for
 IPv6 routes addition / deletion
Date: Wed, 19 Jul 2017 10:36:52 -0600
Message-ID: <ca78d11f-bf7d-5fd3-756b-6faedfd86758@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-15-jiri@resnulli.us>
 <983f0254-9539-213d-f140-63b542d8f23e@gmail.com>
 <20170719163052.GB10775@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33184 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755285AbdGSQgz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:36:55 -0400
Received: by mail-pg0-f50.google.com with SMTP id k14so2603592pgr.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 09:36:55 -0700 (PDT)
In-Reply-To: <20170719163052.GB10775@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 10:30 AM, Ido Schimmel wrote:
>> rif == 0 means the dst device is not related to a port owned by this
>> driver?
> 
> Yes.
> 
>>
>>
>> A lot to process so I am sure I missed the answer to these:
>>
>> 1. How do you handle host routes for local addresses? IPv6 inserts the
>> host and anycast routes with the device set to 'lo' (or VRF device)
>> instead of the device with the address. I have a patch to change this,
>> but needs more testing
> 
> In mlxsw_sp_fib6_entry_type_set() we check for RTF_LOCAL and set the
> FIB entry type to MLXSW_SP_FIB_ENTRY_TYPE_TRAP. Packets hitting these
> routes will be trapped with IP2ME trap ID towards the CPU.

got it. thanks.

> 
>> 2. How are routes with devices unrelated to ports owned by this driver
>> handled?
> 
> They are handled just like any other route, but they don't have a valid
> RIF (for directly connected routes) or an adjacency group (for
> gatewayed routes), so the check in mlxsw_sp_fib_entry_should_offload()
> will return false and they will be programmed to the device with trap
> action, but using a trap ID (RTR_INGRESS0) with a lower traffic class
> than IP2ME, so packets that actually need to be locally received by the
> CPU have a better QoS.

so mlxsw keeps a copy of the complete FIB for IPv4 and IPv6, even routes
unrelated to its ports?
