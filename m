From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 23:56:17 +0300
Message-ID: <20050212205617.GA29146@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <86de38db09518ced8865af09cd79c064@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        romieu@fr.zoreil.com, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org
To: rick jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <86de38db09518ced8865af09cd79c064@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Actually, it may think slow start is being done - there was enough 
> small packet back and forth on the connection before the "heavy 
> transfer" to get cwnd opened

If receiver sent an ACK it still does not mean that sender used it
to increase its cwnd. Particularly, small packet exchange definitely
does not inflate cwnd.


> output.  All the stacks with ACK avoidance with which I am familiar do 
> not make the assumption that the sender is not doing slow-start.  They 
> make sure to send enough ACKs at the beginning (or after packet loss) 
> to allow the sender's cwnd to grow.

Well, we do similar thing with delayed ACKs. And it took a few of runs
of testing to understand that we cannot detect even packet loss reliably
enough. :-)

Actually, those receivers could use the first delayed ACK event as
a sign of failure of their heuristics and block stretching acks for
this connection.

Alexey
