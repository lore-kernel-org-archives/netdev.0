From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:16:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B2647.8080803@us.ibm.com>
References: <20040928223344.GC2975@wotan.suse.de>	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu> <20040929140016.7ffa4e8b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929140016.7ffa4e8b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

  > I think you hit the jackpot John... or at least you're
> on the right trail.
> 
> It seems I'll have to do some send buffer liberation when
> we partially ACK TSO frames.  Since that isn't happening
> currently, this window advancing test never passes until
> the full TSO frame is freed up at the sender side.
> 
> Patch coming...

That was my point to Herbert, Dave - that we can't
rely on Nagle - either we're triggering too early
and not utilizing TSO MTU or we're triggering too
late (waiting for the full TSO frame) depending
on whether we use standard or TSO mss..

We need some heuristic to do partial sends under
TSO. Is that what you are addressing?


thanks,
Nivedita
