From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 22:48:06 +0200
Message-ID: <20050517204806.GF13748@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <m1zmut7l5q.fsf@muc.de> <200505171457.38719.jheffner@psc.edu> <20050517.120950.74749758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, ak@muc.de, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.120950.74749758.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050517.120950.74749758.davem@davemloft.net> 2005-05-17 12:09
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 17 May 2005 14:57:38 -0400
> 
> > It would be better still to have a per-route packet reassembly timeout in 
> > milliseconds.
> 
> I agree.  And if we can setup the infrastructure such that the
> drivers can indicate the speed of the link they are communicating
> on, then we can set sane default values on the automatically
> created subnet routes.

I think we have two separate issues to resolve, first we need
to figure out a way to state the probability of a id wrap, this
can be a very simple pps rate estimator on the driver statistics
for hardware interfaces and something more tricky for virtual
interfaces such as found in xen. I think the link speed is not
reliable enough for this.

The second issue covers the actual defeat of the wraps, we have
to differ between the rare but possible case for long delayed
fragments and short delayed reorderings as caused by SMP. A
combination of both short and long delayed reorderings rarely
happens in practice and if so that's the bigger problem anyway.
The above probability can be used to distinguish these cases
and be more specific. SMP caused fragments have a very local
distribution and thus the window for accepted ids can be smaller
than the one for a long delayed fragment session. So maybe we
can use the above probability as a factor to calculate a window
of accepted ids.
