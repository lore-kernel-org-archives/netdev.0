From: "David S. Miller" <davem@davemloft.net>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 12:28:04 -0800
Message-ID: <20050131122804.75d0611f.davem@davemloft.net>
References: <1107123123.8021.80.camel@jzny.localdomain>
	<20050131135810.GC31837@postel.suug.ch>
	<1107181169.7840.184.camel@jzny.localdomain>
	<20050131151532.GE31837@postel.suug.ch>
	<1107186044.1076.11.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com, nguyendinhnam@gmail.com,
        rmocius@auste.elnet.lt, andre@tomt.net, syrius.ml@no-log.org,
        andy.furniss@dsl.pipex.com, damion@snapgear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107186044.1076.11.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 31 Jan 2005 10:40:44 -0500
jamal <hadi@cyberus.ca> wrote:

> My experience is that you end up dropping no more than a packet in a
> burst with policing before TCP adjusts. Also depending on the gap
> between bursts, that may be the only packet you drop altogether.
> In long flows such as file transfers, avergae of one packet ever gets
> dropped.

Keep in mind that this does not help people with connection
heavy access patterns.  If you have a lot of people doing
small transactions, ACK pacing as well as data traffic
dropping is necessary.

The heart of TCP pacing is ACK rates.  All of it's data
sending is clocked via ACK arrival.

Therefore the best scheme seems to be ACK pacing along
with data dropping.  The ACK pacing is the "nice" policing
where as the data dropping is the big hammer.  Ideally, the
ACK pacing will produce the desired data rate and thus the
data dropping will not be necessary.

ACK pacing is more desirable also because of schemes such
as VEGAS congestion control which wish to test the limits
of a link without any data drops.  It's basic idea is that
"if my delay increases, yet my throughput does not, I am
 doing nothing more than eating router queue space and
 therefore have gone beyond the limits of this path, back off"

I know there are problems with VEGAS, but it is a good example
to use in showing that the way to tame TCP's data sending rate
is by controlling the ACKs not by dropping the data, as a first
order method of policing.
