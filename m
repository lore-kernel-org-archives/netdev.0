From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: udp weirdness
Date: Tue, 24 Sep 2002 08:50:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020924065046.GF392@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm observing some UDP weirdness, or I'd better say some UDP behaviour
that I can't explain.

Two machines: one sending a UDP flow (using sendto) and another receiving 
this UDP flow (using bind + recv). 

When the dgram length is lower that 357 Bytes I observe strange results
at the send side. My home-made udp_tx program gives the following:

$./udp_tx -h 192.168.4.1 -m 357
357 1312621 357.518

357 is the dgram length (in B), 1312621 the number of dgrams sent and 
357.518 the perceived thruput (in Mbits/s). The weirdness is that I
get 357.518 Mbits/s whereas the underlying network is 10Mbits/s!

At the receive side the results are consistent (obviously):

$./udp_rx -m 357
357 29519 8.00884

<netstat -s --udp> on the send machine before and after the run also
gives me such a large amount of sent packets (~1312700), whereas
</sbin/ifconfig> confirms that about 29519 packets have been sent
out.

Below 357 Bytes, the same kind of results are observed. Above 357 Bytes,
the results make more sense to me:

$./udp_tx -h 192.168.4.1 -m 358
358 29505 8.04393

$./udp_rx -m 358
358 29468 8.0179

Does anybody know where I lose packets? And why do I lose them only when
the dgram length is below 357 Bytes?

BTW, I'm running 2.4.18-vanilla w/ the 3c59x driver.

Thx.
-- 
Eric
