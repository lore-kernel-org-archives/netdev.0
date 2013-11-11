From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [patch iproute2] ipaddress: add a black line for each device to
 make the output more readable
Date: Mon, 11 Nov 2013 23:08:30 +0800
Message-ID: <CAPwn2JTQjH54jM5Vhz=7GRMOMW-5AXGGRChZrxeSGdiKN6DeMw@mail.gmail.com>
References: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:41485 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab3KKPIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:08:32 -0500
Received: by mail-wi0-f172.google.com with SMTP id ez12so2297870wid.17
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 07:08:31 -0800 (PST)
In-Reply-To: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/11/11 Hangbin Liu <liuhangbin@gmail.com>:
> When we have multi links, the output huddled together and make it hard to read.
> Let's use the old ifconfig output style.

For example:

Before:
# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:10:18:f4:09:c4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.11/24 brd 192.168.18.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.100.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 2012::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2001::210:18ff:fef4:9c4/64 scope global dynamic
       valid_lft 2086084sec preferred_lft 98884sec
    inet6 fe80::210:18ff:fef4:9c4/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:10:18:f4:09:c5 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:10:18:f4:09:c6 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:10:18:f4:09:c7 brd ff:ff:ff:ff:ff:ff
6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:1b:21:a0:94:b6 brd ff:ff:ff:ff:ff:ff
    inet6 2001::21b:21ff:fea0:94b6/64 scope global dynamic
       valid_lft 2591897sec preferred_lft 604697sec
    inet6 fe80::21b:21ff:fea0:94b6/64 scope link
       valid_lft forever preferred_lft forever
7: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether e4:1f:13:eb:c4:1a brd ff:ff:ff:ff:ff:ff
    inet 10.66.86.93/23 brd 10.66.87.255 scope global eth5
       valid_lft forever preferred_lft forever
    inet 172.16.100.1/24 scope global eth5
       valid_lft forever preferred_lft forever
    inet6 2011::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2620:52:0:4257:e61f:13ff:feeb:c41a/64 scope global dynamic
       valid_lft 2086053sec preferred_lft 98853sec
    inet6 fe80::e61f:13ff:feeb:c41a/64 scope link
       valid_lft forever preferred_lft forever
8: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether e4:1f:13:eb:c4:1b brd ff:ff:ff:ff:ff:ff
9: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether e4:1f:13:eb:c4:1c brd ff:ff:ff:ff:ff:ff
10: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether e4:1f:13:eb:c4:1d brd ff:ff:ff:ff:ff:ff


After:
# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
group default qlen 1000
    link/ether 00:10:18:f4:09:c4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.11/24 brd 192.168.18.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.100.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 2012::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2001::210:18ff:fef4:9c4/64 scope global dynamic
       valid_lft 2086047sec preferred_lft 98847sec
    inet6 fe80::210:18ff:fef4:9c4/64 scope link
       valid_lft forever preferred_lft forever

3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether 00:10:18:f4:09:c5 brd ff:ff:ff:ff:ff:ff

4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether 00:10:18:f4:09:c6 brd ff:ff:ff:ff:ff:ff

5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether 00:10:18:f4:09:c7 brd ff:ff:ff:ff:ff:ff

6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 00:1b:21:a0:94:b6 brd ff:ff:ff:ff:ff:ff
    inet6 2001::21b:21ff:fea0:94b6/64 scope global dynamic
       valid_lft 2591860sec preferred_lft 604660sec
    inet6 fe80::21b:21ff:fea0:94b6/64 scope link
       valid_lft forever preferred_lft forever

7: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
group default qlen 1000
    link/ether e4:1f:13:eb:c4:1a brd ff:ff:ff:ff:ff:ff
    inet 10.66.86.93/23 brd 10.66.87.255 scope global eth5
       valid_lft forever preferred_lft forever
    inet 172.16.100.1/24 scope global eth5
       valid_lft forever preferred_lft forever
    inet6 2011::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2620:52:0:4257:e61f:13ff:feeb:c41a/64 scope global dynamic
       valid_lft 2086016sec preferred_lft 98816sec
    inet6 fe80::e61f:13ff:feeb:c41a/64 scope link
       valid_lft forever preferred_lft forever

8: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether e4:1f:13:eb:c4:1b brd ff:ff:ff:ff:ff:ff

9: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether e4:1f:13:eb:c4:1c brd ff:ff:ff:ff:ff:ff

10: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
default qlen 1000
    link/ether e4:1f:13:eb:c4:1d brd ff:ff:ff:ff:ff:ff

>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/ipaddress.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 1c3e4da..9570f16 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -782,6 +782,7 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
>
>                 print_addrinfo(NULL, n, fp);
>         }
> +       fprintf(fp, "\n");
>         return 0;
>  }
>
> --
> 1.8.1.4
>
