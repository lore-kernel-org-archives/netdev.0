From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 29 Mar 2005 10:58:56 -0800
Message-ID: <4249A570.90709@hp.com>
References: <20050309210442.3e9786a6.davem@davemloft.net>	<4230288F.1030202@ev-en.org>	<20050310182629.1eab09ec.davem@davemloft.net>	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>	<20050311201011.360c00da.davem@davemloft.net>	<20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de>	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>	<20050322074122.GA64595@muc.de>	<20050328155117.7c5de370@dxpl.pdx.osdl.net>	<20050329152538.GF63268@muc.de> <20050329091725.4f955ee7@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050329091725.4f955ee7@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I took the liberty of asking one of the IA64 guru's about the indirect calls. 
This is what he had to say (reposted with his permision if not my complete 
comprehension :)

<excerpt>

McKinley-type cores (includes Madison, etc.)
do not have indirect branch target hardware.  Instead, indirect
branches are executed as follows:

At the time an indirect branch is fetched, the frontend reads the
contents of the branch register that contains the branch target.  The
contents of that register is then used as the predicted target.

For example, "br.call.sptk.many rp=b6" would read register "b6" at the
time the "br.call" is fetched by the frontend and then the contents of
"b6" is used as the predicted target.

This has the following implications:

(1) To _guarantee_ correct prediction, the branch register has to be
     loaded way before the indirect branch direction (at least 6
     front-end L1I cache accesses; which is up to 6 bundle-pairs or 36
     instructions, I believe).

(2) If (1) isn't possible (it often isn't, in small functions),
     another possibility is to test whether the branch targets one of a
     few common targets and, if so, invoke those targets via direct
     branches.  This is generally done automatically by compilers (at
     least if there is PBO info or a programmer-provided hint
     available), but sadly GCC doesn't do this at the moment.

The good news is that since McKinley-types cores don't have
complicated branch-target predictors, misprediction penalty is
_relative_ small (10 cycles).  The bad news is that the network path
is extremely sensitive to even such relatively small penalities, it
does make a significant difference.

As mentioned earlier, we could fix some of the most egregious effects
with a "call_likely" macro which hints which target(s) are the most
likely ones.

</excerpt>

rick jones
netperf feedback always welcome...
