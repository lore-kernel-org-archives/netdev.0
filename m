From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Mon, 06 Jul 2015 17:42:26 +0200
Message-ID: <559AA1E2.2080906@6wind.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com> <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36858 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbbGFPm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:42:29 -0400
Received: by widjy10 with SMTP id jy10so164647187wid.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:42:28 -0700 (PDT)
In-Reply-To: <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2015 17:03, David Ahern a =C3=A9crit :
> This driver borrows heavily from IPvlan and teaming drivers.
>
> Routing domains (VRF-lite) are created by instantiating a device
> and enslaving all routed interfaces that participate in the domain.
> As part of the enslavement, all local routes pointing to enslaved
> devices are re-pointed to the vrf device, thus forcing outgoing
> sockets to bind to the vrf to function.
>
> Standard FIB rules can then bind the VRF device to tables and regular
> fib rule processing is followed.
>
> Routed traffic through the box, is fwded by using the VRF device as
> the IIF and following the IIF rule to a table which is mated with
> the VRF.
>
> Locally originated traffic is directed at the VRF device using
> SO_BINDTODEVICE or cmsg headers. This in turn drops the packet into
> the xmit function of the vrf driver, which then completes the ip look=
up
> and output.
>
> This solution is completely orthogonal to namespaces and allow the L3
> equivalent of vlans to exist allowing the routing space to be
> partitioned.
>
> Example:
>
>     Create vrf 1:
>       ip link add vrf1 type vrf table 5
>       ip rule add iif vrf1 table 5
>       ip rule add oif vrf1 table 5
>       ip route add table 5 prohibit default
>       ip link set vrf1 up
>
>     Add interface to vrf 1:
>       ip link set eth1 master vrf1
>
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> v2:
> - addressed comments from first RFC
> - significant changes to improve simplicity of implementation
History should be put after the '---'.

> ---
ie here.

>   drivers/net/Kconfig  |   7 +
>   drivers/net/Makefile |   1 +
>   drivers/net/vrf.c    | 486 ++++++++++++++++++++++++++++++++++++++++=
+++++++++++
>   include/net/vrf.h    |  71 ++++++++
>   4 files changed, 565 insertions(+)
>   create mode 100644 drivers/net/vrf.c
>   create mode 100644 include/net/vrf.h
