From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: always join solicited-node address
Date: Thu, 31 Oct 2013 16:00:03 +0100
Message-ID: <871u31trik.fsf@nemi.mork.no>
References: <1381685064-24805-1-git-send-email-bjorn@mork.no>
	<20131014005508.GE14021@order.stressinduktion.org>
	<87fvs4s4zc.fsf@nemi.mork.no>
	<20131014155610.GA20327@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34809 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212Ab3JaPBc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 11:01:32 -0400
Received: from nemi.mork.no (ip6-localhost [IPv6:::1])
	by canardo.mork.no (8.14.4/8.14.4) with ESMTP id r9VF1SjQ027341
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 16:01:29 +0100
Received: from bjorn by nemi.mork.no with local (Exim 4.80)
	(envelope-from <bjorn@mork.no>)
	id 1Vbtj9-00027R-K8
	for netdev@vger.kernel.org; Thu, 31 Oct 2013 16:00:03 +0100
In-Reply-To: <20131014155610.GA20327@order.stressinduktion.org> (Hannes
	Frederic Sowa's message of "Mon, 14 Oct 2013 17:56:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> On Mon, Oct 14, 2013 at 09:09:59AM +0200, Bj=C3=B8rn Mork wrote:
>> Yes, but that would also make the IP layer try to resolve IP to link
>> layer addressess both for IPv4 and IPv6, which just won't work. At l=
east
>> not for IPv4, where there just is no way to transport an ARP to the
>> modem.  And I assume it may fail for IPv6 too on any sane device.
>
> I don't think that clearing the IFF_NOARP flag would kill connectivit=
y
> for either IPv4 or IPv6.

It does, because the neigbours cannot be resolved.

> It may compromise security for IPv6 though
> (no idea how the telco network behind the modem looks like).
>
>> > Is this a specific bug of the modem you are using or are all devic=
es
>> > powered by this driver like this?
>>=20
>> Unfortunately I have no IPv6 enabled SIM myself, so I have no
>> information about other devices.  This report was based on user
>> feedback.
>>=20
>> I assume the bug is specific to this firmware implementation, probab=
ly
>> extending to all similar devices from the same vendor.  But it could=
 be
>> more common than that.  The fact that the bug is there indicates tha=
t
>> this works just fine in Windows.
>>=20
>> Yes, I realize that I am in ugly-hack-to-workaround-firmware-issues =
land
>> again... But it sure would be nice to have some way for a driver to
>> indicate that L2 neighbour tables are meaningless, but that any inco=
ming
>> requests should still be answered.
>
> L2 neighbour tables are resolved on demand and won't be queried for t=
he
> link you are talking about (at least for IPv6, but I assume IPv4, too=
).
>
> A new flag should have clear semantics then:
>
> * split IFF_NOARP to IFF_NOARP and IFF_NONDISC
> * split IFF_NOARP to IFF_NOLLRESOLV_RESPONSE and IFF_NOLLRESOLV_MODIF=
Y
>   (each one flag which is applicable for both IPv4 and IPv6)
>
> I tend to lean towards the last alternative but still wonder if this =
is
> just overhead for this one buggy device.

Thanks a lot for your review and thoughts on this.  I do agree 100% wit=
h
your last comment here, and ended up with an in-driver workaround
instead.

It's not beautiful, but at least it doesn't add a lot of core code for
this very special purpose.



Bj=C3=B8rn
