From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Tue, 08 Mar 2011 22:34:26 +0100
Message-ID: <4D76A0E2.6020205@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com> <4D7565BC.4050201@gmail.com> <20110308024356.GV11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34432 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1CHVeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 16:34:31 -0500
Received: by wwi17 with SMTP id 17so1501702wwi.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:34:29 -0800 (PST)
In-Reply-To: <20110308024356.GV11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/03/2011 03:43, Andy Gospodarek a =E9crit :
> On Tue, Mar 08, 2011 at 12:09:48AM +0100, Nicolas de Peslo=FCan wrote=
:
>>
>> After Jiri's last patch series, bond_arp_rcv() is not registered any=
more
>> as a protocol handler on bond0, but directly called from inside
>> bond_handle_frame(), through bond->recv_probe.
>>
>> Because bond_handler_frame() is a rx_handler for the slave interface=
s,
>> bond_arp_rcv() is now called at the slave level and not a the master
>> level anymore.
>>
>> Hence this patch and the reason I thought it should work.
>>
>> Did you tested this patch with Jiri's previous patches applied befor=
e?
>>
>
> No, I have not tested them yet.  I looked at this problem first as
> Jiri's patch did not fix a regression in code that is actually in
> net-next right now.

=46or as far as I understand, the regression was introduced by Jiri's p=
atches that are not yet=20
accepted in net-next-2.6, so this path definitely need the full patch s=
eries to be applied before.=20
And there is no special urgency to fix this regression, because it does=
n't "exist" yet anywhere=20
except in some sandboxes.

This patch change the reinjection to inject at the slave level instead =
of the master level, because=20
in Jiri's patch series, ARP handling moved from a normal protocol handl=
er registered at the master=20
level to the rx_handler at the slave level.

Jiri, do I miss something ?

> I don't have a problem with the work you and Jiri are doing on this
> latest patch series, but the frequency of patch revisions and now
> regressions concerns me.

I agree with your concerns, and this is the reason why Jiri and I are w=
orking hard to try and fight=20
every possible problems in the whole package of patch. I think that, at=
 the end, Jiri and I will=20
have to properly resubmit the whole thing, for the convenient of those =
who will have to decide to=20
accept it or not.

	Nicolas.
