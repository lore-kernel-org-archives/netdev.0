From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 15:03:22 -0700
Message-ID: <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
 <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:54884 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754844Ab2I0WDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:03:43 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so2306763obb.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 15:03:43 -0700 (PDT)
In-Reply-To: <1348769990.5093.1584.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 11:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-09-27 at 20:08 +0200, Eric Dumazet wrote:
>
>>
>> This sounds not feasible with all kind of tunnels, for example IPIP
>> tunnels, or UDP encapsulation, at least with current stack (not OVS)
>>
>> Also note that pushing earlier means forcing the checksumming earlier
>> and it consumes a lot of cpu cycles. Hopefully NIC will help us in the
>> future.
>>
>> Using a napi_struct permits to eventually have separate cpus, and things
>> like RPS/RSS to split the load.
>
> Also please note that my implementation doesnt bypass first IP stack
> traversal (and firewalling if any), so its changing nothing in term
> of existing setups.
>
> So packets that should be forwarded will stay as they are (no tunnels
> decapsulation/recapsulation)
>
> Doing this in the generic GRO layer sounds a bit difficult.

We wouldn't actually do the decapsulation at the point of GRO.  This
is actually pretty similar to what we do with TCP - we merge TCP
payloads even though we haven't done any real IP processing yet.
However, we do check firewall rules later if we actually hit the IP
stack.  GRE would work the same way in this case.

What I'm describing is pretty much exactly what NICs will be doing, so
if that doesn't work we'll have a problem...
