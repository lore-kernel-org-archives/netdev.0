From: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Wed, 29 May 2013 15:13:30 +0200
Message-ID: <20130529151330.22c5c89e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke-LJ9M9ZcSy1A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Barth <cyrus-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, Eric Dumazet
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, j.vimal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Michal Soltys <soltys-R61QfzASbfY@public.gmane.org>, Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>, Patrick
	McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org


I recently discovered that the (traffic control) tc linklayer
calculations for ATM/ADSL have been broken by:
 commit 56b765b79 (htb: improved accuracy at high rates).

Thus, people shaping on ADSL links, using e.g.:
 tc class add ... htb rate X ceil Y linklayer atm overhead 10

Will no-longer get ATM cell tax/overhead adjusted.

How can we solve/fix this?
Perhaps we can change to use the "stab" system instead (as it does
not seem to be broken by the commit).

But how do we facilitate a change to use "stab" system (for all the
scripts using the old option)?

Can we change the iproute2/tc command to handle this transparently, or
should we give an error/warning if someone uses "tc" and "linklayer" on
a kernel above v.3.8. ?


History:
 - My linklayer ATM changes appeared in kernel 2.6.24 (and iproute2 2.6.25)
 - The STAB changes appeared in kernel 2.6.27

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
