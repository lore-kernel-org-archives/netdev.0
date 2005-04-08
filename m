From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Fri, 08 Apr 2005 13:20:33 -0700
Message-ID: <4256E791.7080904@hp.com>
References: <421CF5E5.1060606@ev-en.org>	<20050223135732.39e62c6c.davem@davemloft.net>	<421D1E66.5090301@osdl.org> <421D30FA.1060900@ev-en.org>	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>	<20050309210442.3e9786a6.davem@davemloft.net>	<4230288F.1030202@ev-en.org>	<20050310182629.1eab09ec.davem@davemloft.net>	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>	<20050311201011.360c00da.davem@davemloft.net>	<20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0504081512180.20627@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0504081512180.20627@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 
> For the record, here are some benchmarks from an ia64 over GigE.  I
> set the MTU to 564 so it actually stressed the CPU.  Numbers are
> throughput (10^6 bits/sec).

> Command line used: netperf -H 192.168.1.3 -l -1000000000 -c -C -v 2.

I so rarely see anyone use the byte count limits for -l - nice to know they 
still work :)

FWIW, the argument to -l is passed through netperf's "convert()" routine which 
means you can use K|M|G for powers-of-two kilo, mega and giga; or k|m|g for 
powers of ten:

     netperf -H 192.168.1.3 -l -1g -c -C -v 2

> The sender was a 1-CPU 900 MHz Itanium2.  The receiver was a 1-CPU 2.4 GHz
> Pentium 4.  The sender reported over 99% utilization; the receiver
> reported about 50%.  The NICs were both fiber SysKonnect 9843's connected
> back to back.
> 
>    Normal reno    Modular reno
>         392.77          392.59
>         393.96          393.66
>         393.22          393.72
>         393.12          393.81
>         392.09          393.37
>         393.3           393.58
>         391.81          393.22
>         393.11          394.1
>         391.32          393.77
>         392.94          393.03
> 
> average 392.76          393.49
> stdev   0.79            0.44

Looks like noise.  Fair enough.

rick jones

back to trying to figure-out why netperf IPv6 tests and ping6 won't work with 
local scope addresses but will with global...
