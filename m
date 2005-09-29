From: Guillaume Autran <gautran@mrv.com>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x
 kernels
Date: Thu, 29 Sep 2005 11:34:52 -0400
Message-ID: <433C099C.6060805@mrv.com>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <20050902183656.GA16537@yakov.inr.ac.ru> <Pine.LNX.4.61.0509281223560.30951@ionlinux.tower-research.com> <20050929151729.GA2158@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050929151729.GA2158@ms2.inr.ac.ru>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Sorry Alexey for keeping it quiet but I got pulled away to some other duties for 
the past 3 weeks.

Anyway, the similar problem I was reporting has not been seen since that last 
incident a month ago. We did change, on our application side, some of the 
parameters (aka SO_RCVBUF) that did not need to be set in the first place (bug 
on our side).

This plus your patch seem to have resolve the issues we were having. So, it's 
all good !

Thanks again..
Guillaume.


Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>>Anyway, ignoring this puzzle, the following patch for 2.4 should help.
>>>
>>>
>>>--- net/ipv4/tcp_input.c.orig	2003-02-20 20:38:39.000000000 +0300
>>>+++ net/ipv4/tcp_input.c	2005-09-02 22:28:00.845952888 +0400
>>>@@ -343,8 +343,6 @@
>>>			app_win -= tp->ack.rcv_mss;
>>>		app_win = max(app_win, 2U*tp->advmss);
>>>
>>>-		if (!ofo_win)
>>>-			tp->window_clamp = min(tp->window_clamp, app_win);
>>>		tp->rcv_ssthresh = min(tp->window_clamp, 2U*tp->advmss);
>>>	}
>>>}
>>
>>I'm very happy to report that the above patch, applied to 2.6.12.6, seems 
>>to have cured the TCP window problem we were experiencing.
> 
> 
> Good. I think the patch is to be applied to all mainstream kernels.
> 
> The only obstacle is the second report by Guillaume Autran <gautran@mrv.com>,
> which has some allied characteristics, but after analysis it is something
> impossible, read, cryptic and severe bug. :-( I did not get a responce
> to the last query, so the investigation stalled.
> 
> Alexey
> 

-- 
=======================================
Guillaume Autran
Senior Software Engineer
MRV Communications, Inc.
Tel: (978) 952-4932 office
=======================================

