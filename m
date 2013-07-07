From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Sun, 7 Jul 2013 15:08:10 +0300
Message-ID: <201307071508.10740.jackm@dev.mellanox.co.il>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il> <51D45449.5010604@mellanox.com> <CAL1RGDU0JiGPFEAu87JbxxbHWbgZVsRz1qbz4BvqbCJU9RtRAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDU0JiGPFEAu87JbxxbHWbgZVsRz1qbz4BvqbCJU9RtRAA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 03 July 2013 22:26, Roland Dreier wrote:
> Look at the actual timer code. =A0del_timer_sync() won't work if
> something unrelated re-adds the timer, but it will work if the timer
> itself is what re-adds itself.
>=20
> Documentation/DocBook/kernel-locking.tmpl says:
>=20
> =A0 =A0 =A0 Another common problem is deleting timers which restart
> =A0 =A0 =A0 themselves (by calling <function>add_timer()</function> a=
t the end
> =A0 =A0 =A0 of their timer function). =A0Because this is a fairly com=
mon case
> =A0 =A0 =A0 which is prone to races, you should use
> <function>del_timer_sync()</function>
> =A0 =A0 =A0 (<filename class=3D"headerfile">include/linux/timer.h</fi=
lename>)
> =A0 =A0 =A0 to handle this case. =A0It returns the number of times th=
e timer
> =A0 =A0 =A0 had to be deleted before we finally stopped it from addin=
g itself back
> =A0 =A0 =A0 in.
>=20
> which pretty clearly says that del_timer_sync() will work in this cas=
e.
>=20
> Or look at the code using it in arch/sparc/kernel/led.c for example
> (just one of the first hits in my grep, there are many other
> examples).
>=20
> Not a big deal but I'm pretty sure the flag isn't needed.

Thanks for the feedback, Roland!

You are correct, and I removed the "active" flag in V3 of the patch set=
 (to be submitted shortly).

-Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
