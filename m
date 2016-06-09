From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: brcmfmac: rework function picking free BSS index
Date: Thu, 9 Jun 2016 18:48:31 +0200
Message-ID: <CACna6rxZEnPydDfzpyE2NXz1FSj=PVmT+vWuJ_PdScvGnBmNfQ@mail.gmail.com>
References: <20160609161732.90E20613F6@smtp.codeaurora.org> <87eg86l3zo.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211 development <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87eg86l3zo.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9 June 2016 at 18:30, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:
>
>> Rafa=C5=82 Mi=C5=82ecki wrote:
>>> The old implementation was overcomplicated and slightly bugged in s=
ome
>>> corner cases.
>>>
>>> Consider following state of BSS-es (limited to 6 for simplification=
):
>>> drvr->iflist[0]: { bsscfgidx:0, ndev->name:wlan1, }
>>> drvr->iflist[1]:  (null)
>>> drvr->iflist[2]: { bsscfgidx:2, ndev->name:wlan1-1, }
>>> drvr->iflist[3]: { bsscfgidx:3, ndev->name:wlan1-2, }
>>> drvr->iflist[4]:  (null)
>>> drvr->iflist[5]:  (null)
>>> In such case the next AP interface should bsscfgidx 4 (we don't use=
 1 as
>>> it's reserved for P2P).
>>>
>>> With old code the loop iterations were following:
>>> [ifidx =3D 0] [bsscfgidx =3D 2] [highest =3D 2]
>>> [ifidx =3D 1] [bsscfgidx =3D 2] [highest =3D 2] available =3D true
>>> [ifidx =3D 2] [bsscfgidx =3D 2] [highest =3D 2] bsscfgidx =3D highe=
st + 1
>>> [ifidx =3D 3] [bsscfgidx =3D 3] [highest =3D 2] bsscfgidx =3D highe=
st + 1
>>> [ifidx =3D 4] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
>>> [ifidx =3D 5] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
>>> There were 2 obvious problems:
>>> 1) Having empty BSS at index 1 was resulting in available being alw=
ays
>>>    set to true, even if we would run out of BSS-es.
>>> 2) Calculated bsscfgidx was invalid (3 instead of 4) resulting in d=
river
>>>    not being able to create the 4th AP interface.
>>>
>>> New code is simpler, placed in file where it's really used, handles
>>> running out of free BSS-es and allows using 4 interfaces at the sam=
e
>>> time. It also looks for the first free BSS instead of one after the=
 last
>>> in use. It works well with current driver (which doesn't allow dele=
ting
>>> interfaces) and should be future proof (if we ever allow deleting).
>>>
>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> Thanks, 1 patch applied to wireless-drivers-next.git:
>>
>> d02fb8f14b2d brcmfmac: rework function picking free BSS index
>
> Now that patchwork.kernel.org is finally updated and I fixed my pytho=
n
> script, this is the first time I applied a patch using UTF-8 charset
> directly from patchwork. As it's not exactly easy to get UTF-8 suppor=
t
> right in python, I would very much like to hear if there any issues
> either with the commit below or the email above.
>
> https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-n=
ext.git/commit/?id=3Dd02fb8f14b2d

Look fine, thanks!

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
