From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 16:29:27 +0200
Message-ID: <20090827142927.GA17220@basil.fritz.box>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com> <4A93E36C.8070502@gmail.com> <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com> <4A967FCE.3000807@gmail.com> <87skfdl6qt.fsf@basil.nowhere.org> <4A969566.3070606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Li_Xin2@emc.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752432AbZH0O3c@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A969566.3070606@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 27, 2009 at 04:17:10PM +0200, Eric Dumazet wrote:
> Andi Kleen a =E9crit :
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> >> Now, 7200 seconds might be inappropriate for special needs, and co=
nsidering
> >> there is no way to change tcp_retries2 for a given socket (only ch=
oice being the global
> >> tcp_retries2 setting), I would vote for a change in our stack, to =
*relax* RFC,
> >> and get smaller keepalive timers if possible.
> >=20
> > I think the better fix would be to just to only do that when
> > tcp_retries2 > keep alive time. So keep the existing behaviour
> > with default keep alive, but switch when the user defined
> > a very short keep alive.
> >=20
>=20
> tcp_retries2 is a number of retries, its difficult to derive a time f=
rom it.

That shouldn't be too hard.=20

>=20
> Also, it's not clear what behavior you are refering to.
> Imagine we can be smart and compute tcp_retries2_time (in jiffies) fr=
om tcp_retries2
> If keepalive_timer fires and we have packets in flight, what heuristi=
c do you suggest ?

I didn't suggest to change something at firing time, just pattern
the code you removed with if (keepalive_time > retries2 time)

That's not perfect, but likely good enough.


> if (tp->packets_out || tcp_send_head(sk))
> 	if (tcp_retries2_time < keepalive_time_when(tp))
> 		goto resched;
> elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
> ...
>=20
> What would be the gain ?
> Arming timer exactly every keepalive_time_when(tp)
> instead of keepalive_time_when(tp) - (tcp_time_stamp - tp->rcv_tstamp=
) ?

The gain would be that you don't send unnecessary packets by default (f=
ollowing the RFC), but=20
still give expected behaviour to users who explicitely set short keepal=
ives.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
