From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 00:29:15 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030415.002915.71906095.yoshfuji@linux-ipv6.org>
References: <20030414080347.0af818f7.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: rddunlap@osdl.org
In-Reply-To: <20030414080347.0af818f7.rddunlap@osdl.org>
List-Id: netdev.vger.kernel.org

In article <20030414080347.0af818f7.rddunlap@osdl.org> (at Mon, 14 Apr 2003 08:03:47 -0700), "Randy.Dunlap" <rddunlap@osdl.org> says:

> This patch modifies the ICMPv6 MIB statistics to be collected per
> network-interface instead of globally, as required by RFC 2466
> (ICMPv6 MIB Group).

We, USAGI, have similar code for linux-2.4. (Sorry, I forgot this 
one... :-p)

We store per-interface in inet6_dev{}, because this information blongs 
to inet6 layer.

I'd recommend that we split information per interface
 1) to minimize the /proc file
 2) to minimize the effort to rewrite snmp daemon (e.g. net-snmp)
We use /proc/net/dev_snmp6/{1,2,...}. Example:

# cat /proc/net/dev_snmp6/1
Ip6LastChange                   	1616
Ip6InReceives                   	1108
Ip6InHdrErrors                  	0
Ip6InTooBigErrors               	0
:
Icmp6InMsgs                     	1107
Icmp6InErrors                   	549
Icmp6InDestUnreachs             	1106
:

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
