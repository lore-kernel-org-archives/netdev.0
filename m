From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: timestamping at the mac80211 layer before it hits tc?
Date: Sun, 27 Nov 2011 10:48:09 +0100
Message-ID: <CAA93jw7zdM6+36CnvzcYoSjyMxP+myoX46JSzCGwg7jC5OnwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

My crazy idea at the moment is that since things can spend inordinate
amounts of time in the txqueue in wireless in particular, that moving
(tcp and packet) timestamping to where it enters the queue rather than
hits the wireless device would make a difference. Unless that's
already how it works.

http://www.bufferbloat.net/issues/304#change-1186

The secondary fallout of that is an easier way to expire (probably
rescheduled) packets that have spent too much time in queue.

Eric had put up a (rfc) tc filter a while back that dumped a timestamp
into the private block of the skb...

but...

I kind of like the idea of reusing the existing hwtstamps concept for
the period "queue entrance to queue exit", as a queue is a 'device',
IMHO.

from linux/skbuff.h

* hwtstamps can only be compared against other hwtstamps from
* the same device.
*
* This structure is attached to packets as part of the
* &skb_shared_info. Use skb_hwtstamps() to get a pointer.
*/
struct skb_shared_hwtstamps {
=A0 =A0 =A0 =A0ktime_t hwtstamp;
=A0 =A0 =A0 =A0ktime_t syststamp;
};


Sign me,
lost in a myriad of data paths on a sunday afternoon, wearing an asbest=
os suit

--
Dave T=E4ht
SKYPE: davetaht
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
