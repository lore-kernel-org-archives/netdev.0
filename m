From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Sun, 19 Sep 2004 21:51:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52u0ttr196.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<1095628759.1049.22.camel@jzny.localdomain>
	<20040919193415.6dc96cab.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919193415.6dc96cab.davem@davemloft.net> (David S.
 Miller's message of "Sun, 19 Sep 2004 19:34:15 -0700")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    David> It sounds like a two-stage thing, the first stage lets you
    David> talk on the subnet and get to the IB subnet manager, and
    David> the second stage lets you acually speak IP.  My
    David> understanding, from his description, is that once the
    David> second stage part is complete you don't need to first stage
    David> address information at all.

Pretty much... ARP gives you a unique identifier for the port with the
IP address you're looking for.  Then you need to take that unique
identifier and ask the subnet manager what path to use to get from
your local port to that destination port.  (Talking to the subnet
manager uses an InfiniBand native, non-IP mechanism -- one of the
first things the subnet manager does is go over the whole fabric and
tell each port what path to use to send it queries)

Thanks,
  Roland
