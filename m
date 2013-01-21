From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Mon, 21 Jan 2013 23:01:59 +0100
Message-ID: <87hamab3fs.fsf@nemi.mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-3-git-send-email-bjorn@mork.no>
	<87wqv64gr9.fsf@home.kaliuta.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: Yauheni Kaliuta <y.kaliuta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87wqv64gr9.fsf-jZyLUQyd5ymekGDzARDqUg@public.gmane.org> (Yauheni Kaliuta's message of
	"Mon, 21 Jan 2013 18:56:10 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Yauheni Kaliuta <y.kaliuta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>>> "BM" =3D=3D Bj=C3=B8rn Mork writes:
>
>  > We normally avoid sending ZLPs by padding NTBs with a zero byte
>  > if the NTB is shorter than dwNtbOutMaxSize, resulting in a short
>  > USB packet instead of a ZLP.  But in the case where the NTB length
>  > is exactly dwNtbOutMaxSize and this is an exact multiplum of
>  > wMaxPacketSize, then we must send a ZLP.
>
> The idea of NCM was to avoid extra ZLPs. If your transfer is exactly
> dwNtbOutMaxSize, it's known, you can submit such request on the recei=
ver
> side and you do not need any EOT indicatation, so the frametime can b=
e
> used for useful data.

Yes, that makes sense.  And I understand that both you and Alexey are o=
f
this opinion.

But this idea is by no means made clear (to me) in the spec.  I do not
think the current wording is precise enough to expect every implementor
to understand any such intent.  The only place I find either "short
packet" or ZLP mentioned in the NCM spec is in tables 3-1 and 3-2,
describing the 16bit and 32bit NTH formats, in the description of the
(d)wBlockLength fields.  And even there it is only mentioned in the
context of the special (d)wBlockLength =3D 0x0000 handling.

If the intent was to prevent ZLPs, then it would have been wise to writ=
e
that in the NCM standard. As it stands you have to use a lot of
imagination to read that intent into the current spec.

> I didn't check MBIM specs, but I guess, it wasn't changed. But better=
 get
> Alexey's answer for sure.

No, there are no changes to this area in the MBIM spec AFAIK, so
whatever is correct for NCM is also correct for MBIM.  The question is
what is correct for NCM.

>  > This fixes an issue seen on a Sierra Wireless MC7710 device
>  > where the transmission would fail whenever we ended up padding
>  > the NTBs to max size.
>
> Is it buggy?

That is not unlikely. However, if so then it is buggy in a way we just
have to deal with because Windows does...

But before claiming this to be a bug I would like to understand how we
have come to this conclusion that NCM and MBIM devices should not need
ZLPs.  I agree that it would have made sense to have such a requirement=
,
but I cannot find it in the spec.

I would also like to know how Windows works around this issue, because =
I
am pretty confident that this device works with Windows 8.  If it didn'=
t
then the firmware wouldn't have been flagged for release, and it is.  I=
t
is even distributed by 3rd party integrators (aka laptop vendors).



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
