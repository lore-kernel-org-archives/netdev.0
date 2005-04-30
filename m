From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 23:55:50 +0200
Message-ID: <20050430215550.GH577@postel.suug.ch>
References: <1114879817.8929.117.camel@localhost.localdomain> <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net> <1114882045.8929.123.camel@localhost.localdomain> <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain> <20050430200848.GF577@postel.suug.ch> <1114894202.8929.165.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114894202.8929.165.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1114894202.8929.165.camel@localhost.localdomain> 2005-04-30 16:50
> I think we may have to define what the scope of classid is. It seems to
> me the scope needs to be _local_ to either ingress or egress. 
> OTOH, something like a fwmark is _global_. 
> At least this is what my thoughts were when doing that piece.
> Using those rules, the situation Patrick describes on violates this
> (because stolen packets still maintain the classid), yours doesnt -
> unless we change the scope of classid. 

Right, although I would define local as per device on either ingress
or egress. What I'm looking for in particular is a way to transfer
classification decisions from one device to another. A common case
for this is if a packet enters the packet, gets encapsulated and
leaves the host in some kind of tunnel. It's pretty hard to do
classification on the tunnel device so you want to do it before
the encapsulation and copy the result over to the tunnel. We can
use nfmark for this but i'd rather have a well defined variable
for this.
