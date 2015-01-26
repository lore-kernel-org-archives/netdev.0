From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: replacing a rt6_info needs to purge possible
 propagated rt6_infos too
Date: Mon, 26 Jan 2015 08:02:09 -0800
Message-ID: <1422288129.29618.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkundrak@v3.sk
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56534 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755558AbbAZQCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 11:02:12 -0500
Received: by mail-pd0-f181.google.com with SMTP id g10so12577555pdj.12
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 08:02:11 -0800 (PST)
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

Hi Hannes

Was this bug added in commit 4a287eba2de395713d8b2b2aeaa69fa086832d34
("IPv6 routing, NLM_F_* flag support: REPLACE and EXCL flags support,
warn about missing CREATE flag") ?

Thanks !
