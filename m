From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 21:22:04 +0200
Message-ID: <4DA89ADC.7040808@gmail.com>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com> <10227.1302893590@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>,
	netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52936 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554Ab1DOTWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 15:22:09 -0400
Received: by wwa36 with SMTP id 36so3568431wwa.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 12:22:08 -0700 (PDT)
In-Reply-To: <10227.1302893590@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2011 20:53, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 15/04/2011 18:44, Micha=C5=82 G=C3=B3rny a =C3=A9crit :
>>> Hello,
>>>
>>> I'd like to file a feature request for the bonding driver. Currentl=
y,
>>> there is no way for userspace to know whether the driver actually g=
ets
>>> a MAC address. This results in the fact that dhcpcd sends MAC-less =
DHCP
>>> packets through bonding device if it is started before bond gets an=
y
>>> slaves.
>>
>> A similar subject, involving bridge instead of bonding, was discusse=
d a
>> few weeks ago in this thread:
>> http://marc.info/?l=3Dlinux-netdev&m=3D129939017116310&w=3D2
>>
>> In particular, I suggested to apply Stephen's suggestion not only to=
 bridge but also to bonding.
>>
>> (http://marc.info/?l=3Dlinux-netdev&m=3D129948385024680&w=3D2)
>>
>> A bonding device should not report link up to userspace until at lea=
st one slave is present and up.
>>
>> And possibly, a bonding device should report link down if all slaves=
 are down or all slave were removed.
>>
>> Jay, Andy, does this sounds sensible to you?
>
> 	I was just reading their bug and doing an experiment; I don't
> see that bonding reports carrier up until there's at least one slave
> (even if it's configured up), e.g.,
>
> # modprobe bonding
> # ifconfig bond0 up
> # cat /sys/class/net/bond0/carrier
> 0
> # echo +eth5>  /sys/class/net/bond0/bonding/slaves
> # cat /sys/class/net/bond0/carrier
> 1
>
> 	If there's a slave, there's a MAC assigned, since bond_enslave
> sets the master's MAC before it calls bond_set_carrier.
>
> 	In bond_create, as soon as register_netdevice returns, we call
> netif_carrier_off, and it stays off until bond_enslave runs
> successfully.

Agreed.

> 	Is there some race window there between the register and the
> netif_carrier_off?

It might be that dhcpd does not wait for link to be up before starting =
to send DHCP requests.

	Nicolas.
