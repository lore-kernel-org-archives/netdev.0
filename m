From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Sun, 1 May 2005 01:58:09 +0200
Message-ID: <20050430235809.GI577@postel.suug.ch>
References: <1114879817.8929.117.camel@localhost.localdomain> <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net> <1114882045.8929.123.camel@localhost.localdomain> <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain> <20050430200848.GF577@postel.suug.ch> <1114894202.8929.165.camel@localhost.localdomain> <20050430215550.GH577@postel.suug.ch> <1114900485.8929.171.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114900485.8929.171.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1114900485.8929.171.camel@localhost.localdomain> 2005-04-30 18:34
> On Sat, 2005-30-04 at 23:55 +0200, Thomas Graf wrote:
> > 
> > Right, although I would define local as per device on either ingress
> > or egress. What I'm looking for in particular is a way to transfer
> > classification decisions from one device to another. A common case
> > for this is if a packet enters the packet, gets encapsulated and
> > leaves the host in some kind of tunnel. It's pretty hard to do
> > classification on the tunnel device so you want to do it before
> > the encapsulation and copy the result over to the tunnel. We can
> > use nfmark for this but i'd rather have a well defined variable
> > for this.
> 
> Perhaps we can reuse classid by flagging somewhere? 
> A good place to do it is tc_verdict. There a few bits still left.
> We could set a bit to say the meaning of classid to be global vs local.

Sounds good to me, I'm not quite sure if I still have a good enough
picture of your action code. Let's assume we have ematches and an
action setting the classid at ingress. The action sets the above flag
to state the global scope. The packet passes the stack and the
classid gets copied into the new encapsulated packet. On the egress
device we have something like a nop action assigning the classid
to res->classid. How do we make sure that the classid remains
untouched even if the packet passes a dummy device in between having
actions configured? Can we we still have functional actions on
this dummy device?
