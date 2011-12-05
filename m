From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Time in Queue, bufferbloat, and... our accidentally interplanetary network
Date: Mon, 5 Dec 2011 10:05:27 +0100
Message-ID: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I was tickled to see that expiring packets based on 'time in queue'
was already a
key design feature of the IPN,

http://www.science20.com/interwebometry/lessons_nasa_can_learn_internet=
-84861

and the idea was suggested also independently in saturday's CACM
article's comments...

http://queue.acm.org/detail.cfm?id=3D2071893


Making decisions based on time in queue (TiQ), rather than length of
queue, would
seem to be a win, especially for wireless, but also for  that does
'soft' traffic
shaping with HTB-like qdiscs and sub qdiscs. Anything that is not runni=
ng
at GigE plus speeds would benefit.

=2E.. since basically what's been happening with bufferbloat is a too e=
arly
implementation of the IPN, with detours between here and the moon!

=2E.. and so far I haven't seen any major theoretical holes in with TiQ=
, except
for deciding as to how long is too long as to consider a packet as 'exp=
ired',
(which can be measured in ms or 10s of ms), and having reasonably
monotonic time.

I just wish I (or someone) could come up with a way to implement it in =
Linux
without multiple layer violations. skb->queuestamp has a nice ring to i=
t, but
when I look at this portion of the stack I freely admit quivering in ig=
norance
and fear.

I did a bit of work on a set of timestamping fifos, but realized that
it was the
entire queue's duration from entrance to exit (through multiple schedul=
ing
qdiscs) was what needed to be  measured, and the drop/no drop decision
needs to be made as late as possible - and preferably, the queue being
pulled from needs the next packet pulled forward so as to inform the
receiver that congestion is happening...

And Eric dumazet also produced a preliminary patch a few weeks back
that tied timestamping to before the head of a queue, but that tried to=
 use a
reserved field in the skb that appears from points A to Z is not guaran=
teed
to be preserved.

Thoughts?

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
