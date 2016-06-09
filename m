From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: brcmfmac: rework function picking free BSS index
Date: Thu, 09 Jun 2016 19:30:03 +0300
Message-ID: <87eg86l3zo.fsf@purkki.adurom.net>
References: <20160609161732.90E20613F6@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky \(Zhenhui\) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160609161732.90E20613F6-4h6buKAYkuurB/BPivuO70B+6BGkLq7r@public.gmane.org> (Kalle Valo's
	message of "Thu, 9 Jun 2016 16:17:32 +0000 (UTC)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:

> Rafa=C5=82 Mi=C5=82ecki wrote:
>> The old implementation was overcomplicated and slightly bugged in so=
me
>> corner cases.
>>=20
>> Consider following state of BSS-es (limited to 6 for simplification)=
:
>> drvr->iflist[0]: { bsscfgidx:0, ndev->name:wlan1, }
>> drvr->iflist[1]:  (null)
>> drvr->iflist[2]: { bsscfgidx:2, ndev->name:wlan1-1, }
>> drvr->iflist[3]: { bsscfgidx:3, ndev->name:wlan1-2, }
>> drvr->iflist[4]:  (null)
>> drvr->iflist[5]:  (null)
>> In such case the next AP interface should bsscfgidx 4 (we don't use =
1 as
>> it's reserved for P2P).
>>=20
>> With old code the loop iterations were following:
>> [ifidx =3D 0] [bsscfgidx =3D 2] [highest =3D 2]
>> [ifidx =3D 1] [bsscfgidx =3D 2] [highest =3D 2] available =3D true
>> [ifidx =3D 2] [bsscfgidx =3D 2] [highest =3D 2] bsscfgidx =3D highes=
t + 1
>> [ifidx =3D 3] [bsscfgidx =3D 3] [highest =3D 2] bsscfgidx =3D highes=
t + 1
>> [ifidx =3D 4] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
>> [ifidx =3D 5] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
>> There were 2 obvious problems:
>> 1) Having empty BSS at index 1 was resulting in available being alwa=
ys
>>    set to true, even if we would run out of BSS-es.
>> 2) Calculated bsscfgidx was invalid (3 instead of 4) resulting in dr=
iver
>>    not being able to create the 4th AP interface.
>>=20
>> New code is simpler, placed in file where it's really used, handles
>> running out of free BSS-es and allows using 4 interfaces at the same
>> time. It also looks for the first free BSS instead of one after the =
last
>> in use. It works well with current driver (which doesn't allow delet=
ing
>> interfaces) and should be future proof (if we ever allow deleting).
>>=20
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Thanks, 1 patch applied to wireless-drivers-next.git:
>
> d02fb8f14b2d brcmfmac: rework function picking free BSS index

Now that patchwork.kernel.org is finally updated and I fixed my python
script, this is the first time I applied a patch using UTF-8 charset
directly from patchwork. As it's not exactly easy to get UTF-8 support
right in python, I would very much like to hear if there any issues
either with the commit below or the email above.

https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-nex=
t.git/commit/?id=3Dd02fb8f14b2d

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
