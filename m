From: Werner Almesberger <wa@almesberger.net>
Subject: WLAN power saving: brain dump
Date: Tue, 16 Nov 2004 11:30:27 -0300
Message-ID: <20041116113027.A4026@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is just a brain dump, so that the ideas are out in public.
Some day, I might actually implement this, unless somebody else
beats me to it :-)

These reflections are my own. I made them while reading 
specifications of WLAN cards with growing horror.

Looking at WLAN cards, they uniformly seem to have excessive
power consumption even if just laying in wait. This is
particularly annoying for devices with otherwise very low
power consumption, such as PDAs.

It would seem to me that the typical use of such a device would
allow for completely powering down the WLAN card if not needed.
In particular, all packets reaching a normal PDA are in response
to some previous and comparably recent emission from that device.

Furthermore, we generally have a fairly good idea of when we
still want to send something, and, although to a lesser extent,
when we're expecting incoming data.

So actively powering down a WLAN card while idle could use the
following inputs:

- an indication of whether any socket has a non-empty send queue
- the time since the last time all send queues were empty (we want
  to have a certain cool-off period, for various reasons, including
  connectionless activity like ARP or UDP)
- an indication if whether any sockets have a read or a poll or
  select for reading pending (this is very unreliable, but may
  provide useful input with some appliations)
- time since the last successful reception
- an indication of whether any sockets have pending out-of-order
  data
- a manual override

All this should be keyed by interface. Things to consider:

- the time and power it takes to bring a WLAN card back online
- the time we regularly have to wait for something to happen
  even if we seem to be able, e.g. the delay between sending an
  HTTP GET and a response (if we can get hints from the Web
  client, no guessing is needed here)
- the correlation between idle time and future idleness from the
  user

There's probably more. For a proof of concept implementation, it
should be sufficient to consider ARP, DNS, SSH/SCP, and HTTP(S).

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
