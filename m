From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 22:56:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929225635.061f2405.ak@suse.de>
References: <20040928223344.GC2975@wotan.suse.de>
	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
	<20040929090103.GB18671@wotan.suse.de>
	<20040929125644.40358b42.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929125644.40358b42.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 12:56:44 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Wed, 29 Sep 2004 11:01:03 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > > Does this help?
> > 
> > Possible. I don't have any plans to change the receiver because
> > it works well for most cases.
> > 
> > The problem must be still in the sender.
> 
> "Must"?  So you've proven that the ack-every-22 packets behavior
> is due entirely to the sender?

Just saying the the kernel was tested in a very wide range 
of very wide range of workloads and environments and there are no 
known TCP issues.

Also the test that John wanted to diable has been in Linux practically
forever (irc dates back to Eric Schenk's work in 2.0) 

And other kernels talking to it get ok performance, all the problems
only started with the TSO changes in 2.6.9rc.

> 
> If you put 2.6.9-current on both ends and this makes things go smoothly
> that is an important data point and nobody else is seeing the behavior
> you are at the moment.
> 
> Personally, all of my bets are on the 2.6.5 frankenstein kernel
> as the culprit :-)

Umm, the TCP stack is pretty vanilla 2.6.5. 

Ok, I ran it talking to a 2.6.9rc2bk11+instanto-oops-patchkit
bandaided to avoid oops kernel with a tg3.

Actually I tried to, with TSO on on the sender it doesn't finish the normal
10s netperf standard test even in 30s. Then the sender eventually crashed
even with unit-at-a-time turned off.

And the crash starts looking a bit less like a compiler issue. Does it really 
work for you?

Part of the trace. It looks like the new kernel has really
bad problems with acking.

22:45:06.065031 10.23.202.15.32777 > 10.23.202.31.32775: . ack 11585 win 7240 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065042 10.23.202.15.32777 > 10.23.202.31.32775: . ack 13033 win 7964 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065047 10.23.202.15.32777 > 10.23.202.31.32775: . ack 14481 win 8688 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065052 10.23.202.15.32777 > 10.23.202.31.32775: . ack 15929 win 9412 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065061 10.23.202.15.32777 > 10.23.202.31.32775: . ack 17377 win 10136 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065066 10.23.202.15.32777 > 10.23.202.31.32775: . ack 18825 win 10860 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065091 10.23.202.15.32777 > 10.23.202.31.32775: . ack 20273 win 11584 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065254 10.23.202.31.32775 > 10.23.202.15.32777: . 20273:21721(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065317 10.23.202.15.32777 > 10.23.202.31.32775: . ack 21721 win 12308 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065322 10.23.202.31.32775 > 10.23.202.15.32777: . 21721:23169(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065327 10.23.202.31.32775 > 10.23.202.15.32777: . 23169:24617(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065331 10.23.202.31.32775 > 10.23.202.15.32777: . 24617:26065(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065335 10.23.202.31.32775 > 10.23.202.15.32777: . 26065:27513(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065339 10.23.202.31.32775 > 10.23.202.15.32777: P 27513:28961(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065348 10.23.202.15.32777 > 10.23.202.31.32775: . ack 23169 win 13032 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065353 10.23.202.15.32777 > 10.23.202.31.32775: . ack 24617 win 13756 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065358 10.23.202.15.32777 > 10.23.202.31.32775: . ack 26065 win 14480 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065368 10.23.202.15.32777 > 10.23.202.31.32775: . ack 27513 win 15204 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065372 10.23.202.15.32777 > 10.23.202.31.32775: . ack 28961 win 15928 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065529 10.23.202.31.32775 > 10.23.202.15.32777: . 28961:30409(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065534 10.23.202.31.32775 > 10.23.202.15.32777: . 30409:31857(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065540 10.23.202.31.32775 > 10.23.202.15.32777: . 31857:33305(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065577 10.23.202.31.32775 > 10.23.202.15.32777: . 33305:34753(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065581 10.23.202.31.32775 > 10.23.202.15.32777: . 34753:36201(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065585 10.23.202.31.32775 > 10.23.202.15.32777: P 36201:37649(1448) ack 1 win 1460 <nop,nop,timestamp 325947 352118> (DF)
22:45:06.065603 10.23.202.15.32777 > 10.23.202.31.32775: . ack 30409 win 16022 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065608 10.23.202.15.32777 > 10.23.202.31.32775: . ack 31857 win 16022 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065613 10.23.202.15.32777 > 10.23.202.31.32775: . ack 33305 win 16022 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065622 10.23.202.15.32777 > 10.23.202.31.32775: . ack 37649 win 16022 <nop,nop,timestamp 352118 325947> (DF)
22:45:06.065771 10.23.202.31.32775 > 10.23.202.15.32777: . 37649:39097(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065778 10.23.202.31.32775 > 10.23.202.15.32777: . 39097:40545(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065784 10.23.202.31.32775 > 10.23.202.15.32777: . 40545:41993(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065847 10.23.202.31.32775 > 10.23.202.15.32777: . 41993:43441(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065851 10.23.202.31.32775 > 10.23.202.15.32777: . 43441:44889(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065855 10.23.202.31.32775 > 10.23.202.15.32777: . 44889:46337(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065858 10.23.202.31.32775 > 10.23.202.15.32777: . 46337:47785(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065862 10.23.202.31.32775 > 10.23.202.15.32777: . 47785:49233(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352118> (DF)
22:45:06.065900 10.23.202.15.32777 > 10.23.202.31.32775: . ack 49233 win 16022 <nop,nop,timestamp 352119 325948> (DF)
22:45:06.066152 10.23.202.31.32775 > 10.23.202.15.32777: . 49233:50681(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066159 10.23.202.31.32775 > 10.23.202.15.32777: . 50681:52129(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066165 10.23.202.31.32775 > 10.23.202.15.32777: . 52129:53577(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066172 10.23.202.31.32775 > 10.23.202.15.32777: . 53577:55025(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066208 10.23.202.31.32775 > 10.23.202.15.32777: . 55025:56473(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066212 10.23.202.31.32775 > 10.23.202.15.32777: . 56473:57921(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066216 10.23.202.31.32775 > 10.23.202.15.32777: . 57921:59369(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066219 10.23.202.31.32775 > 10.23.202.15.32777: P 59369:60817(1448) ack 1 win 1460 <nop,nop,timestamp 325948 352119> (DF)
22:45:06.066263 10.23.202.15.32777 > 10.23.202.31.32775: . ack 60817 win 16022 <nop,nop,timestamp 352119 325948> (DF)



-Andi
