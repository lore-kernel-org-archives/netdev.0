From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Connection reset by peer - need a patch
Date: Sat, 28 Feb 2009 12:03:11 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902281114570.26961@wrl-59.cs.helsinki.fi>
References: <20090227150755.GE2796@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Pascal GREGIS <pgs@synerway.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49409 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbZB1KDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 05:03:14 -0500
In-Reply-To: <20090227150755.GE2796@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009, Pascal GREGIS wrote:

> I have a very annoying bug that seems to be well known today.
> It happens on a backup server that issue a "Connection reset by peer" 
> while the other side does not reset or stop the connection. 

If I understand you correct you lost synchronization between hosts...
If so I'd suggest you start tracking what's getting dropped/discarded and 
where (it might affect only a single direction). Any middlebox is outright 
a suspect :-). Tcpdump (on both host, and possibly on intermediate nodes 
ifaces if losses in between are found from the end host tcpdumps), mibs 
(/proc/net/netstat, for in-host discards) and strace are there to help 
you onward. Even if it's not lost syncronization you basically use 
the same tools.

> I have found a report that seems very similar on this mailing list :
> http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/4/28/1628834
> 
> this sends to the commit 7951f0b03a63d657c72c7d54d306ef3357e7e604
> Author: Daniel Lezcano <...
> Date: Thu Apr 10 20:53:10 2008 -0700
>     [NETNS][IPV6] tcp - assign the netns for timewait sockets
> 
> and gives a simple patch that adds the line 
>     tw->tw_net = sk->sk_net;
> somewhere in the function inet_twsk_alloc (in the file net/ipv4/inet_timewait_sock.c).

I don't think you're on a right track with that lead...

> Right, but the problem is that I use a kernel 2.6.21.1 and cannot 
> upgrade my whole kernel easily. And in the kernel 2.6.21.1, network 
> namespaces don't seem to exist, so I cannot apply this simple patch.

...as that bug was introduced along with network namespaces, so for sure 
you won't need that fix for anything that doesn't have them. <update>Ah,
DaveM already told that</update>.

> I am in a very uncomfortable situation because this bug is causing 
> harmfull problems on all the backup servers of my company and as I said 
> above, upgrading the kernel is not really possible at this time. > 
> Does anyone know what I could do to solve this ?

Unfortunately it's a bit same for us as we don't act as a support for 
random, ancient kernels (if it's a distro kernel you can probably ask 
them but basically you'll need more information that what's available in 
this mail to actually solve the problem)... I gave you some directions how 
these problems are located in general regardless of kernel version.

On the other hand, please don't hesitate to report/ask from us if you have 
a recent enough kernel and encounter some problems.


-- 
 i.
