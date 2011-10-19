From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 14:58:22 +0200
Message-ID: <4E9EC96E.8020303@broadcom.com>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Nico Schottelius" <nico-linux-20111017@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319028563.8416.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2011 02:49 PM, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 14:36 +0200, Nico Schottelius a =C3=
=A9crit :
>> Hello,
>>
>> I've
>>
>> Eric Dumazet [Tue, Oct 18, 2011 at 02:24:25PM +0200]:
>>> Must be a mutex_unlock(some_mltex) missing somewhere.
>>>
>>> Then later, a process holding RTNL is blocking on mutex_lock(some_m=
utex)
>>>
>>> Try a "CONFIG_LOCKDEP=3Dy" enabled build
>>
>> Did so, attached is the dmesg output after 3x suspend.
>>
>> It also seems this bug gets more / only triggered when I loose the
>> connection to a wpa2-eap network that is defined like this:
>>
>> network=3D{
>>    ssid=3D"eth"
>>   id_str=3D"eth-802.2x"
>>    key_mgmt=3DWPA-EAP
>>    proto=3DWPA2
>>    eap=3DTTLS
>>    pairwise=3DCCMP TKIP
>>    group=3DCCMP TKIP
>>    phase2=3D"auth=3DMSCHAPV2"
>>    identity=3D"MYNAME"
>>    password=3D"forgottoremoveit"
>> }
>>
>> Hope the dmesg output helps and we can remove the problem soon
>> and making the mba finally almost completly usable :-)
>>
>=20
> Sorry, no CONFIG_LOCKDEP in your config or dmesg. Maybe you sent a
> previous dmesg/config file ?
>=20
> Note that you have "CONFIG_LOCKDEP_SUPPORT=3Dy", not "CONFIG_LOCKDEP=3D=
y"
>=20

Hi Eric,

Are there any configuration setting needed that CONFIG_LOCKDEP depends =
on?

Gr. AvS
