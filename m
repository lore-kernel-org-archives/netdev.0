From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Fri, 6 May 2005 00:55:55 +0300
Message-ID: <200505060055.55778.m.iatrou@freemail.gr>
References: <200505051928.32496.m.iatrou@freemail.gr> <427A7F5B.8050704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <427A7F5B.8050704@hp.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the date was Thursday 05 May 2005 23:17, Rick Jones wrote:


> What settings, if any, did you use for -s, -S and in particular -m in
> netperf?

-s 0 -S 0 -m 16384

For both ends:

/proc/sys/net/core/wmem_max:   16777216
/proc/sys/net/core/rmem_max:   16777216
/proc/sys/net/ipv4/tcp_rmem:   16384    349520  16777216
/proc/sys/net/ipv4/tcp_wmem:   16384    262144  16777216

> I seem to recall that some of the stack defaults for SO_SNDBUF (IIRC) would
> result in netperf sending 16KB at a time into the connection - once you
> sent the MTU above 16K you may have started running into issues with Nagle
> and delayed ACK?  

The problem firstly appears at 12KB...

> You could try some tests adding a test-specific -D to 
> disable Nagle, or -C to set TCP_CORK, or use -m to set the send size to
> say, 32KB.

I 've already tested -m 32KB and its the same as 16KB. 
I will try -D and -C too.

> It might be good to add CPU utilization figures - for 2.3pl1 that means
> editing the makefile to add a -DUSE_PROC_STAT and recompiling.  Or you can
> grab netperf 2.4.0-rc3 from:
>
> ftp://ftp.cup.hp.com/dist/networking/benchmarks/netperf/experimental/
>
> if you cannot find it elsewhere, and that will (try to) compile-in the
> right CPU utilization mechanism automagically.

I already did a custom CPU usage instrumentation (based on infos 
from /proc/stat -- the latest netperf does the same thing, doesn't it?) and 
it seems that system has plenty of idle time (up to 50% if I recall correct)

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece
