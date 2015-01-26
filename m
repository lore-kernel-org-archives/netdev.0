From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH net] ipv6: replacing a rt6_info needs to purge possible
 propagated rt6_infos too
Date: Mon, 26 Jan 2015 16:36:16 +0100
Message-ID: <1422286576.6384.7.camel@v3.sk>
References: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shell.v3.sk ([195.168.3.45]:46695 "EHLO shell.v3.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755734AbbAZPqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 10:46:10 -0500
In-Reply-To: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-26 at 15:11 +0100, Hannes Frederic Sowa wrote:
> Lubomir Rintel reported that during replacing a route the interface
> reference counter isn't correctly decremented.
> 
> To quote bug <https://bugzilla.kernel.org/show_bug.cgi?id=91941>:
> | [root@rhel7-5 lkundrak]# sh -x lal
> | + ip link add dev0 type dummy
> | + ip link set dev0 up
> | + ip link add dev1 type dummy
> | + ip link set dev1 up
> | + ip addr add 2001:db8:8086::2/64 dev dev0
> | + ip route add 2001:db8:8086::/48 dev dev0 proto static metric 20
> | + ip route add 2001:db8:8088::/48 dev dev1 proto static metric 10
> | + ip route replace 2001:db8:8086::/48 dev dev1 proto static metric 20
> | + ip link del dev0 type dummy
> | Message from syslogd@rhel7-5 at Jan 23 10:54:41 ...
> |  kernel:unregister_netdevice: waiting for dev0 to become free. Usage count = 2
> |
> | Message from syslogd@rhel7-5 at Jan 23 10:54:51 ...
> |  kernel:unregister_netdevice: waiting for dev0 to become free. Usage count = 2
> 
> During replacement of a rt6_info we must walk all parent nodes and check
> if the to be replaced rt6_info got propagated. If so, replace it with
> an alive one.
> 
> Reported-by: Lubomir Rintel <lkundrak@v3.sk>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_fib.c | 45 ++++++++++++++++++++++++++-------------------
>  1 file changed, 26 insertions(+), 19 deletions(-)

Tested-by: Lubomir Rintel <lkundrak@v3.sk>

Thank you!
Lubo
