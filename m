From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Patch: IPv6/AMD64: bug in net/ipv6/ndisc.c
Date: Fri, 30 Jan 2004 08:37:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040130.083743.20740540.yoshfuji@linux-ipv6.org>
References: <20040129221538.J24747@fi.muni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kas@informatics.muni.cz
In-Reply-To: <20040129221538.J24747@fi.muni.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040129221538.J24747@fi.muni.cz> (at Thu, 29 Jan 2004 22:15:38 +0100), Jan Kasprzak <kas@informatics.muni.cz> says:

> while compiling the kernel (2.6.1) I have spotted the following warning:
> 
> net/ipv6/ndisc.c: In function `ndisc_router_discovery':
> net/ipv6/ndisc.c:1113: warning: comparison is always true due to limited range of data type
:

> The corresponding lines are these:
> 
>                 __u32 rtime = ntohl(ra_msg->retrans_timer);
>                                                                                 
> Here --->       if (rtime && rtime/1000 < (MAX_SCHEDULE_TIMEOUT/HZ)) {
>                         rtime = (rtime*HZ)/1000;
>                         if (rtime < HZ/10)
>                                 rtime = HZ/10;
>                         in6_dev->nd_parms->retrans_time = rtime;
>                 }
:

> The MAX_SCHEDULE_TIMEOUT is #defined to LONG_MAX in include/linux/sched.h,
> which is 2^63-1 or so on AMD64. I propose the following fix:
:

+#define MAX_SCHEDULE_TIMEOUT_32 (MAX_SCHEDULE_TIMEOUT/HZ > (1U<<31) ? \
+	(1U<<31) : MAX_SCHEDULE_TIMEOUT/HZ)

Well,... ok for now.

For long term solution, I think it is better to store timing variables 
in "unsinged long" type instead of int. 
I think there's several places to be fixed.
We'll need proc_doulongvec_jiffies(), proc_doulongvec_userhz_jiffies().

--yoshfuji
