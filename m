From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Wed, 06 Nov 2013 09:11:40 +0100
Message-ID: <5279F9BC.7060600@6wind.com>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <52792499.3030201@6wind.com> <20131105205744.GK8832@order.stressinduktion.org>
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
Received: from mail-we0-f174.google.com ([74.125.82.174]:51203 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab3KFILp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 03:11:45 -0500
Received: by mail-we0-f174.google.com with SMTP id u56so4501158wes.19
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 00:11:43 -0800 (PST)
In-Reply-To: <20131105205744.GK8832@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/11/2013 21:57, Hannes Frederic Sowa a =C3=A9crit :
> On Tue, Nov 05, 2013 at 06:02:17PM +0100, Nicolas Dichtel wrote:
>> Le 29/10/2013 13:40, Hannes Frederic Sowa a =C3=A9crit :
>>> On Tue, Oct 29, 2013 at 09:37:06AM -0000, David Laight wrote:
>>>>> Note that you don't even need to put the DHCP protocol core into =
the
>>>>> kernel to fix the promiscuous problem.  You just have to use the
>>>>> current kernel interfaces correctly.
>>>>>
>>>>> It used to be the case a very long time ago that you couldn't eve=
n
>>>>> receive broadcast UDP datagrams on a socket until an address was
>>>>> configured on it.
>>>>>
>>>>> So everyone turns on promiscuous mode and uses RAW sockets or
>>>>> AF_PACKET.
>>>>>
>>>>> Stupid?  yes.
>>>>
>>>> Not only that, but the dhcp client could use a normal UDP socket
>>>> to keep the lease renewed - I suspect it has only ever needed
>>>> to use the BPF interface (I didn't think it set promiscuous)
>>>> when acquiring the initial lease.
>>>
>>> Yes, this is a very unfortunate situation. From my experience it is=
 not
>>> that
>>> easy to get a patch merged into isc-dhcp.
>>>
>>> It seems not that invasive to switch from af_packet to an udp socke=
t with
>>> SO_BROADCAST set.
>> If I remember well, another problem is to be able to send these pack=
ets with
>> 0.0.0.0 when another IP address is available on the system:
>>
>> RFC2131
>> 4.1 Constructing and sending DHCP messages
>> ...
>>     DHCP messages broadcast by a client prior to that client obtaini=
ng
>>     its IP address must have the source address field in the IP head=
er
>>     set to 0.
>>
>> We made a patch (never proposed upstream) to add a socket option to =
keep
>> this 0.0.0.0 address.
>> If people are interested, I can try to port it on net-next.
>
> Yes, this indeed is a problem for a socket only dhcp client. I would =
make the
> appropriate changes to isc-dhcp if you submit such a patch.
Ok, I will try to do this for the end of the week.


Nicolas
