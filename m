From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 16:50:02 -0400
Message-ID: <1114894202.8929.165.camel@localhost.localdomain>
References: <1114879817.8929.117.camel@localhost.localdomain>
	 <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net>
	 <1114882045.8929.123.camel@localhost.localdomain>
	 <4273CAB7.6080403@trash.net>
	 <1114890709.8929.147.camel@localhost.localdomain>
	 <20050430200848.GF577@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430200848.GF577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 22:08 +0200, Thomas Graf wrote:

> I've been using tc_classid to communicate between ingress and egress
> without the need for netfilter but this is something personal. This
> meant to remove the tc_classid = 0 in tcf_action_exec and a have
> smallish action set it at ingress to pick it up again with the meta
> ematch at egress.
> 

I think we may have to define what the scope of classid is. It seems to
me the scope needs to be _local_ to either ingress or egress. 
OTOH, something like a fwmark is _global_. 
At least this is what my thoughts were when doing that piece.
Using those rules, the situation Patrick describes on violates this
(because stolen packets still maintain the classid), yours doesnt -
unless we change the scope of classid. 


> > I see the issue with classid leaking - perhaps specific actions could
> > reset it when they steal packets? We should also reset it if the packet
> > is stolen.
> 
> Definitely.

Just thinking about that: _exec() can reset classid if packet is stolen
and not transfer it back to classifier.
I think the forward path is to have the actions reset it. We would just
have to make it the rule described somewhere or have a macro someone
call every time they steal a packet... 

> I'm not yet certain on this subject, I have a strong feeling that
> something like tc_classid will be needed but not as in its current
> use. Can we postpone this for 1-2 weeks so I can submit my new
> ematch patches? This would give us something to use as a basis for
> a discussion.

If we are going to redefine the scope of where a classid applies, then
we can discuss it any time.

cheers,
jamal
