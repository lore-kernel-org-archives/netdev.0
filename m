From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 01:25:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927232554.GB15825@wotan.suse.de>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu> <20040927160411.22b44f48.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927160411.22b44f48.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The reason Andi Kleen didn't see any improvements from limiting
> 'factor' is that he is using short lived connections.  If you

The netperf test is about 10s - not really short lived and should
be enough for slow start.

> have a connection up for long enough, this allows the congestion
> window to grow and then it doesn't matter.
> 
> Something like the following is what I have been talking about.
> I am able to reproduce the problem here locally and the following

Cool.

> makes it go away.
> 
> Andi, Anton, and niv, can you confirm it does so for you too?

Unfortunately not - with the patch applied I still get 27MB/s

Looking at the tcpdump the ack clock goes completely out of sync,
the ratio is 4 packets per ack. The sender seems to send packets
faster than the target can ack them. It eventually stops for a 
short time until it gets the ack


01:16:26.034669 10.23.202.31.32777 > 10.23.202.10.34491: P 1983065:1984513(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034713 10.23.202.10.34491 > 10.23.202.31.32777: . ack 1984513 win 63712 <nop,nop,timestamp 53583052 4294889148> (DF)
01:16:26.034902 10.23.202.31.32777 > 10.23.202.10.34491: . 1984513:1985961(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034910 10.23.202.31.32777 > 10.23.202.10.34491: . 1985961:1987409(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034916 10.23.202.31.32777 > 10.23.202.10.34491: . 1987409:1988857(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034921 10.23.202.31.32777 > 10.23.202.10.34491: . 1988857:1990305(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034926 10.23.202.31.32777 > 10.23.202.10.34491: . 1990305:1991753(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.034998 10.23.202.10.34491 > 10.23.202.31.32777: . ack 1991753 win 63712 <nop,nop,timestamp 53583052 4294889148> (DF)
01:16:26.035144 10.23.202.31.32777 > 10.23.202.10.34491: . 1991753:1993201(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035152 10.23.202.31.32777 > 10.23.202.10.34491: . 1993201:1994649(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035158 10.23.202.31.32777 > 10.23.202.10.34491: . 1994649:1996097(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035163 10.23.202.31.32777 > 10.23.202.10.34491: . 1996097:1997545(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035169 10.23.202.31.32777 > 10.23.202.10.34491: P 1997545:1998993(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035214 10.23.202.10.34491 > 10.23.202.31.32777: . ack 1998993 win 63712 <nop,nop,timestamp 53583052 4294889148> (DF)
01:16:26.035393 10.23.202.31.32777 > 10.23.202.10.34491: . 1998993:2000441(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035401 10.23.202.31.32777 > 10.23.202.10.34491: . 2000441:2001889(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)
01:16:26.035406 10.23.202.31.32777 > 10.23.202.10.34491: . 2001889:2003337(1448) ack 1 win 1460 <nop,nop,timestamp 4294889148 53583052> (DF)


-Andi
