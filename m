From: Ronghua Zhang <rz5b@cs.virginia.edu>
Subject: Re: [PATCH] proportional share accept()
Date: Thu, 4 Mar 2004 16:52:22 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.51.0403041650210.10672@mamba.cs.Virginia.EDU>
References: <Pine.LNX.4.44.0403030009510.4963-100000@dyn319495.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vivek Kashyap <kashyapv@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0403030009510.4963-100000@dyn319495.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is not surprising, since using iptable means every packet, inbound or
outbound, has to be changed.

My scheme does not have this overhead either, for it only involves moving
open_request among the accept queues.

Ronghua

On Thu, 4 Mar 2004, Vivek Kashyap wrote:

> The following results show the efficacy of the patch for proportional share
> accept queues.
>
> I utilised Apache with no changes in configuration. Then used httperf to
> on three different machines. Did not change any parameters
> on the server or the client machines. Ran httperf to get the default test.html
> page repeatedly:
> /httperf --server xx.xx.xx.xx --port 80 --uri /test.html --rate 2000 \
> 	--num-conn 100000 --num-call 1 --timeout 5
>
> Three clients simultaneously bombarded the server. When the shares patch is
> not used the three clients get about equal service.
>
> With the proportional shares patch the favoured client gets a proportional
> number of its requests services in much shorter time.
>
> With port redirection the results are much poorer. The conntrack module is
> randomly dropping some of the requests too since its hash table gets full. The
> application will further require modification to provide proportional shares
> which is much more work.
>
> 1. The results without utilising the shares are:
>
> Total: connections 41993 requests 37195 replies 36951 test-duration 52.984 s
> Reply rate [replies/s]: min 646.1 avg 723.0 max 946.5 stddev 95.1 (10 samples)
> Reply time [ms]: response 151.3 transfer 0.0
>
> Total: connections 41972 requests 37132 replies 37081 test-duration 52.996 s
> Reply rate [replies/s]: min 674.7 avg 724.9 max 805.3 stddev 35.1 (10 samples)
> Reply time [ms]: response 95.0 transfer 0.0
>
> Total: connections 47171 requests 43037 replies 42991 test-duration 53.122 s
> Reply rate [replies/s]: min 777.2 avg 844.2 max 895.1 stddev 39.3 (10 samples)
> Reply time [ms]: response 92.1 transfer 0.0
>
> 2. With proportional share patch:
>
>  The shares are were assigned in the ratio: 1:3:6. The results are listed
> in order:
>
> Total: connections 21566 requests 14695 replies 14251 test-duration 52.947 s
> Reply rate [replies/s]: min 208.0 avg 268.0 max 730.0 stddev 162.4 (10 samples)
> Reply time [ms]: response 518.3 transfer 0.0
>
> Total: connections 41016 requests 34110 replies 34060 test-duration 52.981 s
> Reply rate [replies/s]: min 632.9 avg 667.9 max 707.5 stddev 20.1 (10 samples)
> Reply time [ms]: response 204.4 transfer 0.0
>
> Total: connections 71264 requests 67089 replies 67008 test-duration 53.003 s
> Reply rate [replies/s]: min 1214.3 avg 1323.1 max 1366.7 stddev 44.2 (10 samples)
> Reply time [ms]: response 110.5 transfer 0.0
>
>
> 3. Port redirect test
>
> As a test case then modified httpd.conf to listen on three ports 8081/82/83.
> Used iptables REDIRECT target to forward the packets to these ports. The
> clients still communicate with port 80. As expected the results are not as
> good.
>
> Total: connections 33104 requests 27385 replies 26845 test-duration 54.992 s
> Reply rate [replies/s]: min 325.8 avg 534.9 max 868.5 stddev 205.0 (10 samples)
> Reply time [ms]: response 300.1 transfer 0.0
>
> Total: connections 28022 requests 21536 replies 21391 test-duration 54.994 s
> Reply rate [replies/s]: min 2.0 avg 427.8 max 686.8 stddev 211.7 (10 samples)
> Reply time [ms]: response 309.8 transfer 0.0
>
> Total: connections 27452 requests 21045 replies 20907 test-duration 54.992 s
> Reply rate [replies/s]: min 1.4 avg 418.1 max 632.7 stddev 208.2 (10 samples)
> Reply time [ms]: response 310.0 transfer 0.0
>
> Vivek
>
>
>
