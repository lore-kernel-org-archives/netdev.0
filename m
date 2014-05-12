From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: icmp: account for ICMP out errors because of socket limit
Date: Mon, 12 May 2014 12:48:10 +0800
Message-ID: <5370528A.1000806@gmail.com>
References: <53703DC0.2070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Tao, Yue" <Yue.Tao@windriver.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, zhuyj <zyjzyj2000@gmail.com>
To: eric.dumazet@gmail.com, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53703DC0.2070204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Eric && David

This patch is similar to the following patch.

commit 1f8438a853667d48055ad38384c63e94b32c6578
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Sat Apr 3 15:09:04 2010 -0700

     icmp: Account for ICMP out errors

     When ip_append() fails because of socket limit or memory shortage,
     increment ICMP_MIB_OUTERRORS counter, so that "netstat -s" can report
     these errors.

     LANG=C netstat -s | grep "ICMP messages failed"
         0 ICMP messages failed

     For IPV6, implement ICMP6_MIB_OUTERRORS counter as well.

     # grep Icmp6OutErrors /proc/net/dev_snmp6/*
     /proc/net/dev_snmp6/eth0:Icmp6OutErrors                     0
     /proc/net/dev_snmp6/lo:Icmp6OutErrors                       0

     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

Best Regards!
Zhu Yanjun

On 05/12/2014 11:19 AM, zhuyj wrote:
> Hi, Eric && David
>
>  ____           ______________
> |    |         |              |
> | PC |<------->| MIPS 32 core |
> |____|         |______________|
>
> When ping from a PC to a board (MIPS 32 core), because of socket limit,
> ping echo will fail. But ICMP_MIB_OUTERRORS counter is not incremented.
> In this case, "netstat -s" can not report these errors.
>
> This patch will fix this problem. Now it is in the attachment. Please 
> check it.
>
> Best Regards!
> Zhu Yanjun
