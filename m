From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 2.6.0-test11: dst_cache_overflow causing unresponsive box
Date: Tue, 2 Dec 2003 18:56:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16332.53835.297235.589786@robur.slu.se>
References: <072501c3b874$2542ae70$15fea8c0@fortress>
	<16332.27919.502097.988522@robur.slu.se>
	<20031202032606.28db927b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, francois@baligant.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031202032606.28db927b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



David S. Miller writes:

 > Let us assume, for the sake of back of the envelope calculations, that
 > all 90k TCP connections speak to unique destinations.  Let us further
 > assume that all of them have at least one packet in flight.
 > 
 > This means the routing cache must be able to hold at least 90k entries.
 > All of these routing cache entires will be referenced by the packets
 > in the TCP retransmission queues of all the sockets, and thus the
 > entries are unreclaimable.
 > 
 > You are setting net.ipv4.route.max_size to 655360 which should be more
 > than enough.  But you also have to make the net.ipv4.route.gc_thresh
 > more reasonable as well, perhaps 90K as a test.
 > 
 > If net.ipv4.route.gc_thresh is lower than 90K and my assertions above
 > hold, then the kernel will try to garbage collect too early, all the
 > routing cache entries will be in use and therefore uncollectable,
 > and you'll get the message you're seeing.
 > 
 > Try to pump up gc_thresh and see if that helps.

 Yes better tuning as gc_thresh and max_size is in better balance but max_size
 is same so I'll guess we collect unreclaimable entries util we see dst overflow 
 still'. The long time before overflow is suspect "hours to days" We have to 
 ask if this has ever worked before?
 
 I'll guess number of hash buckets should be increased for systems like this.

 
 Cheers.
						--ro
