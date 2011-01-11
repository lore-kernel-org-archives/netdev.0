From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 12 Jan 2011 05:32:03 +0900
Message-ID: <AANLkTik+2udoJ6JyZMhkd1yhr2W9hSWO_vD_zdm+BoOG@mail.gmail.com>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
 <20110108175028.GA22308@riccoc20.at.omicron.at> <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
 <1294678145.3068.6.camel@work-vm> <AANLkTikdg4Pb5c4wcCU3d3Eku=mpiW_TEkBz0A2VPdVp@mail.gmail.com>
 <1294693597.3068.12.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1294693597.3068.12.camel@work-vm>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 11, 2011 at 6:06 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrot=
e:
> On Tue, 2011-01-11 at 05:45 +0900, Kuwahara,T. wrote:
>> On Tue, Jan 11, 2011 at 1:49 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> w=
rote:
>> > Leapsecond processing is done via an absolute hrtimer. Thus when t=
he
>> > time offset is set, the hrtimers that should have expired will fir=
e
>> > (just like with settimeofday) and the adjustment will then be made=
=2E
>>
>> How do you convert relative time to absolute time? =C2=A0It's not tr=
ivial
>> because TAI offset is also a variable.
>
> I don't believe I understand what you're getting at.
>
> The proposed interface is almost identical in functionality to a
> userland application doing the following:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0offset =3D my_calculate_offset();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0clock_gettime(CLOCK_REALTIME, &now);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0newtime =3D my_add_ts(now, offset);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0settimeofday(&newtime, 0);
>
> The only difference is that you avoid the error from the delay betwee=
n
> the gettime call and the settime call. It just adds the offset direct=
ly
> to the CLOCK_REALTIME.

=46or example, what time was it 3 seconds after 2008-12-31 23:59:59?
You may say, of course it's 2009-01-01 00:00:02.  But it's not true.
You wonder why?  Because a leap second had been added at midnight.

	unix time   UTC     offset
	---------- -------- ---
	1230767997 23:59:57  -2
	1230767998 23:59:58  -1
	1230767999 23:59:59   0
	1230768000 23:59:60   1 (leap second)
	1230768000 00:00:00   2
	1230768001 00:00:01   3
	1230768002 00:00:02   4

That's why I said it's not trivial, and that your patch is broken and
thus useless.  Unfortunately, there's no remedy for this as long as a
nonlinear timescale such as the unix time is being used, since the
leap second insertion/deletion is a non-deterministic event.
