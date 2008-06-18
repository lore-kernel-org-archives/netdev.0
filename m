From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] udp: sk_drops handling
Date: Wed, 18 Jun 2008 10:11:39 +0800
Message-ID: <48586EDB.2060809@cn.fujitsu.com>
References: <48582D35.40201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56283 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759565AbYFRCPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 22:15:33 -0400
In-Reply-To: <48582D35.40201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet said the following on 2008-6-18 5:31:
> In commits 33c732c36169d7022ad7d6eb474b0c9be43a2dc1 ([IPV4]: Add raw drops
> counter) and a92aa318b4b369091fd80433c80e62838db8bc1c ([IPV4]: Add raw
> drops
> counter),
> Wang Chen added raw drops counter for /proc/net/raw & /proc/net/raw6
> 
> This patch adds this capability to UDP sockets too (/proc/net/udp &
> /proc/net/udp6).
> 
> This means that 'RcvbufErrors' errors found in /proc/net/snmp can be also
> be examined for each udp socket.
> 
> # grep Udp: /proc/net/snmp
> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors
> Udp: 23971006 75 899420 16390693 146348 0
> 
> # cat /proc/net/udp
>  sl  local_address rem_address   st tx_queue rx_queue tr tm->when
> retrnsmt  ---
> uid  timeout inode ref pointer drops
>  75: 00000000:02CB 00000000:0000 07 00000000:00000000 00:00000000
> 00000000  ---
>   0        0 2358 2 ffff81082a538c80 0
> 111: 00000000:006F 00000000:0000 07 00000000:00000000 00:00000000
> 00000000  ---
>   0        0 2286 2 ffff81042dd35c80 146348
> 
> In this example, only port 111 (0x006F) was flooded by messages that
> user program
> could not read fast enough. 146348 messages were lost.
> 

How about other place, such as, rxrpc_data_ready() also inc UDP_MIB_INERRORS.

