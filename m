From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 10:52:12 -0700
Message-ID: <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:41355 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752861Ab2I0Rwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:52:34 -0400
Received: by obbuo13 with SMTP id uo13so2046825obb.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 10:52:33 -0700 (PDT)
In-Reply-To: <1348750130.5093.1227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 5:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add GRO capability to IPv4 GRE tunnels, using the gro_cells
> infrastructure.
>
> Tested using IPv4 and IPv6 TCP traffic inside this tunnel, and
> checking GRO is building large packets.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

When I was thinking about doing this, my original plan was to handle
GRO/GSO by extending the current handlers to be able to look inside
GRE and then loop around to process the inner packet (similar to what
is done today with skb_flow_dissect() for RPS).  Is there a reason to
do it in the device?

Pushing it earlier/later in the stack obviously increases the benefit
and it will also be more compatible with the forthcoming OVS tunneling
hooks, which will be flow based and therefore won't have a device.

Also, the next generation of NICs will support this type of thing in
hardware so putting the software versions very close to the NIC will
give us a more similar abstraction.
