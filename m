From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 11:50:14 +0200
Message-ID: <20080328094413.M11383@visp.net.lb>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net> <20080328052543.M60286@visp.net.lb> <47EC8701.1080604@cosmosbay.com> <20080328073854.M73368@visp.net.lb> <47ECA24C.10803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:50834 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbYC1JuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 05:50:24 -0400
In-Reply-To: <47ECA24C.10803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will try do so, 


And i have a bit more information, not sure if it is useful. I took risk and 
running now one more loaded router, without nat this time. It has significant 
less load, but maybe i will catch something here also.

Here is dmesg i got
[   23.280155] dst_total: 4 delayed: 1 work_perf: 0 expires: 600 elapsed: 1 us
[   23.888719] dst_total: 5 delayed: 1 work_perf: 0 expires: 1600 elapsed: 1 
us
[   25.489486] dst_total: 11 delayed: 0 work_perf: 1 expires: 4294967295 
elapsed: 2 us
[   67.187254] dst_total: 23980 delayed: 1 work_perf: 0 expires: 600 elapsed: 
2 us
[   67.807126] dst_total: 24452 delayed: 1 work_perf: 0 expires: 1600 
elapsed: 3 us
[   69.453570] dst_total: 25103 delayed: 0 work_perf: 2 expires: 4294967295 
elapsed: 3 us
>>> here i run "ip route flush cache"
[  278.911357] dst_total: 16855 delayed: 2 work_perf: 0 expires: 600 elapsed: 
2 us
[  279.530432] dst_total: 16866 delayed: 2 work_perf: 0 expires: 1600 
elapsed: 1 us
[  281.197568] dst_total: 16901 delayed: 2 work_perf: 0 expires: 3100 
elapsed: 1 us
[  284.425797] dst_total: 16981 delayed: 2 work_perf: 0 expires: 4981 
elapsed: 1 us
[  289.665137] dst_total: 17067 delayed: 2 work_perf: 0 expires: 8000 
elapsed: 1 us
[  297.960978] dst_total: 17219 delayed: 2 work_perf: 0 expires: 11000 
elapsed: 1 us
[  309.379867] dst_total: 17426 delayed: 2 work_perf: 0 expires: 14100 
elapsed: 2 us
[  323.972039] dst_total: 17629 delayed: 2 work_perf: 0 expires: 18196 
elapsed: 2 us
[  342.831626] dst_total: 13563 delayed: 2 work_perf: 0 expires: 23000 
elapsed: 2 us
[  366.592260] dst_total: 13830 delayed: 2 work_perf: 0 expires: 28000 
elapsed: 2 us
[  395.753299] dst_total: 14142 delayed: 2 work_perf: 0 expires: 33000 
elapsed: 2 us
[  429.952513] dst_total: 13156 delayed: 3 work_perf: 0 expires: 600 elapsed: 
2 us
[  430.565783] dst_total: 13164 delayed: 3 work_perf: 0 expires: 1600 
elapsed: 1 us
[  432.267868] dst_total: 13184 delayed: 3 work_perf: 0 expires: 3100 
elapsed: 1 us
[  435.457375] dst_total: 13220 delayed: 3 work_perf: 0 expires: 5700 
elapsed: 2 us
[  441.355880] dst_total: 13279 delayed: 3 work_perf: 0 expires: 8000 
elapsed: 2 us
[  449.567527] dst_total: 13363 delayed: 3 work_perf: 0 expires: 11000 
elapsed: 1 us
[  461.027956] dst_total: 13507 delayed: 3 work_perf: 0 expires: 14000 
elapsed: 2 us
[  475.568361] dst_total: 12084 delayed: 3 work_perf: 0 expires: 18000 
elapsed: 2 us

Is expires values appearing 4294967295 normal?
Btw i am doing ip route flush cache only manually, normally it never happens 
on this machines.

On Fri, 28 Mar 2008 08:46:20 +0100, Eric Dumazet wrote
> Denys Fedoryshchenko :
> > Already patched and tested, it doesn't change anything.
> >
> >
> 
> We still leak dsts somewhere.
> 
> You could try git bisect, or try to patch net/core/dst.c so that 
> dst_gc_task() (line 83) displays
> route informations for say 10 first entries found in the dst_busy_list
> (refcnt, interface, source IP, dest IP, things like that) that could 
> ring a bell given your netfilter rules or network conf.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

