From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 17:31:05 +0300
Message-ID: <20050212143105.GB27456@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050211170958.17fcde21.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > In some cases at least if the sender does not completely fill cwnd the
> > ACKs will  be delayed.  And IIRC under 2.6.10 with TSO enabled, the
> > sender does not always  fill cwnd.
> 
> At a maximum, "1/tcp_tso_win_divisor" of the cwnd will ever be left
> empty.
> 
> By default, this is 1/8 of the cwnd.

In any case, receiver cannot know sender cwnd, so that "fill" or "not fill"
is is not a question.

What is broken in that implementation is that it does not feel slow start.
ACK avoidance while slow start is certain disaster. Currrent theory is that
MacOS X thinks that we do not do slow start.

Alexey
