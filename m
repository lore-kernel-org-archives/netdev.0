From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:50:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929145050.71afa1ac.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
	<415B24C0.2020208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, herbert@gondor.apana.org.au,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <415B24C0.2020208@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 14:10:24 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> I just crashed too, no backtrace. netperf tcp stream test,
> and was on bk14 + dave's 5 patches, p4/e1000 -> Intel Pentium
> M proc (1.7GHz). Going to repeat on slower SMPs with serial
> console, get more info..

I can reproduce this now, it has to do with some weird combinations
of packet loss and SACK'ing.  It's one of the BUG_ON() assertions
triggering in tcp_tso_acked() as I suspected in Andi's first report.

Working on a fix.
