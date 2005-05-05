From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Thu, 05 May 2005 13:17:31 -0700
Message-ID: <427A7F5B.8050704@hp.com>
References: <200505051928.32496.m.iatrou@freemail.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Iatrou <m.iatrou@freemail.gr>
In-Reply-To: <200505051928.32496.m.iatrou@freemail.gr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Iatrou wrote:
> Hi,
> I did several benchmarks using Intel e1000 NIC and it seems there is a
> network throughput problem for MTU > 12000 (e1000 supports up to 16110
> MTU).
> 
> Configuration:
> Two identical PCs, connected back to back, Intel Xeon 2.8GHz (SMP/SMT
> disabled), 512MB RAM, e1000 (82546EB)
> 
> Linux 2.6.11.7
> netperf 2.3pl1

What settings, if any, did you use for -s, -S and in particular -m in netperf?

I seem to recall that some of the stack defaults for SO_SNDBUF (IIRC) would 
result in netperf sending 16KB at a time into the connection - once you sent the 
MTU above 16K you may have started running into issues with Nagle and delayed 
ACK?  You could try some tests adding a test-specific -D to disable Nagle, or -C 
to set TCP_CORK, or use -m to set the send size to say, 32KB.

It might be good to add CPU utilization figures - for 2.3pl1 that means editing 
the makefile to add a -DUSE_PROC_STAT and recompiling.  Or you can grab netperf 
2.4.0-rc3 from:

ftp://ftp.cup.hp.com/dist/networking/benchmarks/netperf/experimental/

if you cannot find it elsewhere, and that will (try to) compile-in the right CPU 
utilization mechanism automagically.

rick jones
