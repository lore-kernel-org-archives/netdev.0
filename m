From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Stop using tasklets for bottom halves
Date: Mon, 7 Sep 2009 21:16:38 -0700
Message-ID: <43e72e890909072116v33ecafc4ma7f5a68825f14e9@mail.gmail.com>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
	<20090907171406.6a4b6116@nehalam> <1252376254.21261.2052.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt Smith <Matt.Smith-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kevin Hayes <kevin-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>, ic.felix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1252376254.21261.2052.camel-f9ZlEuEWxVcI6MkJdU+c8EEOCMrvLtNR@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 7, 2009 at 7:17 PM, Steven Rostedt<rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wro=
te:
> On Mon, 2009-09-07 at 17:14 -0700, Stephen Hemminger wrote:
>> On Mon, 7 Sep 2009 15:58:50 -0700
>> "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> > A while ago I had read about an effort to consider removing taskle=
ts
>> > [1] or at least trying to not use them. I'm unaware of the progres=
s in
>> > this respect but since reading that article have always tried to
>> > evaluate whether or not we need tasklets on wireless drivers. I ha=
ve
>> > also wondered whether work in irq context in other parts of the ke=
rnel
>> > can be moved to process context, a curious example being timers. I=
'll
>> > personally be trying to using only process context on bottom halve=
s on
>> > future drivers but I figured it may be a good time to ask how seri=
ous
>> > was avoiding tasklets or using wrappers in the future to avoid irq
>> > context is or is it advised. Do we have a general agreement this i=
s a
>> > good step forward to take? Has anyone made tests or changes on a
>> > specific driver from irq context to process context and proven the=
re
>> > are no significant advantages of using irq context where you would
>> > have expected it?
>> >
>> > Wireless in particular should IMHO not require taskets for anythin=
g
>> > time sensitive that I can think about except perhaps changing chan=
nels
>> > quickly and to do that appropriately also process pending RX frame=
s
>> > prior to a switch. It remains to be seen experimentally whether or=
 not
>> > using a workqueue for RX processing would affect the time to switc=
h
>> > channels negatively but I doubt it would be significant. I hope to
>> > test that with ath9k_htc.
>> >
>> > What about gigabit or 10 Gigabit Ethernet drivers ? Do they face a=
ny
>> > challenges which would yet need to be proven would not face issues
>> > when processing bottom halves in process context?
>> >
>> > [1] http://lwn.net/Articles/239633/
>> >
>> > =C2=A0 Luis
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> > More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info=
=2Ehtml
>>
>> Why not use NAPI, which is soft irq? Almost all 1G and 10G drivers
>> use NAPI.
>>
>> Process context is too slow.
>
> Well, I'm hoping to prove the opposite. I'm working on some stuff tha=
t I
> plan to present at Linux Plumbers. I've been too distracted by other
> things, but hopefully I'll have some good numbers to present by then.

What day in specific was this planned for at Plumbers?

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
