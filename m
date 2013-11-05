From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 05 Nov 2013 18:02:17 +0100
Message-ID: <52792499.3030201@6wind.com>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:41258 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab3KERCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 12:02:21 -0500
Received: by mail-bk0-f49.google.com with SMTP id w14so3629809bkz.8
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 09:02:19 -0800 (PST)
In-Reply-To: <20131029124010.GA15762@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/10/2013 13:40, Hannes Frederic Sowa a =C3=A9crit :
> On Tue, Oct 29, 2013 at 09:37:06AM -0000, David Laight wrote:
>>> Note that you don't even need to put the DHCP protocol core into th=
e
>>> kernel to fix the promiscuous problem.  You just have to use the
>>> current kernel interfaces correctly.
>>>
>>> It used to be the case a very long time ago that you couldn't even
>>> receive broadcast UDP datagrams on a socket until an address was
>>> configured on it.
>>>
>>> So everyone turns on promiscuous mode and uses RAW sockets or
>>> AF_PACKET.
>>>
>>> Stupid?  yes.
>>
>> Not only that, but the dhcp client could use a normal UDP socket
>> to keep the lease renewed - I suspect it has only ever needed
>> to use the BPF interface (I didn't think it set promiscuous)
>> when acquiring the initial lease.
>
> Yes, this is a very unfortunate situation. From my experience it is n=
ot that
> easy to get a patch merged into isc-dhcp.
>
> It seems not that invasive to switch from af_packet to an udp socket =
with
> SO_BROADCAST set.
If I remember well, another problem is to be able to send these packets=
 with
0.0.0.0 when another IP address is available on the system:

RFC2131
4.1 Constructing and sending DHCP messages
=2E..
    DHCP messages broadcast by a client prior to that client obtaining
    its IP address must have the source address field in the IP header
    set to 0.

We made a patch (never proposed upstream) to add a socket option to kee=
p
this 0.0.0.0 address.
If people are interested, I can try to port it on net-next.

Nicolas
