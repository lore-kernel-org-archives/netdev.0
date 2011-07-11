From: Ben Greear <greearb@candelatech.com>
Subject: Re: recommended way to support duplicate IP addresses on different
 VLANs?
Date: Mon, 11 Jul 2011 08:56:06 -0700
Message-ID: <4E1B1D16.7060803@candelatech.com>
References: <4E1B0F86.2040508@mail.usask.ca> <201107111804.26500.remi@remlab.net> <4E1B1B33.5060300@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>,
	Chris Friesen <cbf123@mail.usask.ca>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56734 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014Ab1GKP4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 11:56:13 -0400
In-Reply-To: <4E1B1B33.5060300@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2011 08:48 AM, Chris Friesen wrote:
> On 07/11/2011 09:04 AM, R=E9mi Denis-Courmont wrote:
>> Le lundi 11 juillet 2011 17:58:14 Chris Friesen, vous avez =E9crit :
>>> Hi all,
>>>
>>> We've got a server that sits on multiple VLANs. Each VLAN is segreg=
ated
>>> and doesn't know about the others. The IP address ranges in each of=
 the
>>> VLANs may overlap, and the server may be assigned the same IP addre=
ss in
>>> multiple VLANs.
>
>>> Is there any other way to deal with this scenario?
>
>
>> Or then binding sockets to devices (SO_BINDTODEVICE) might work.
>
> Hmm...SO_BINDTODEVICE looks interesting. I would imagine we'd still n=
eed
> to do some funky stuff around ARP handling.

arp_filter should help.

Also, you may want to use conn-trck tables.  This lets packets coming
in one or more interfaces use a specific conn-track cache.  Might help
keep the identical IPs from colliding in their conn tracking.

iptables -t raw -A PREROUTING -i eth0.7 -j CT --zone 7

Thanks,
Ben

>
> Chris
>
>
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

