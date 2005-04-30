From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 22:08:48 +0200
Message-ID: <20050430200848.GF577@postel.suug.ch>
References: <1114879817.8929.117.camel@localhost.localdomain> <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net> <1114882045.8929.123.camel@localhost.localdomain> <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114890709.8929.147.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1114890709.8929.147.camel@localhost.localdomain> 2005-04-30 15:51
> On Sat, 2005-30-04 at 20:13 +0200, Patrick McHardy wrote:
> 
> > Since it only has such a short lifetime (action function sets it,
> > tcf_action_exec() clears it after changing classification result),
> > it would be less wasteful to just pass the classification result
> > to the actions. This would also avoid that skbs with tc_classid
> > already set can reach tcf_action_exec() (for example through mirred).
> > 
> > What do you think?
> 
> You mean not passing it back via skbs but through something else?
> What do you have in mind?
> It does sound distasteful for either changing the ->act()
> parametrization just so we can have a classid passed back or provide a
> spot for it in struct tc_action since only some actions will need to
> change it. 

I've been using tc_classid to communicate between ingress and egress
without the need for netfilter but this is something personal. This
meant to remove the tc_classid = 0 in tcf_action_exec and a have
smallish action set it at ingress to pick it up again with the meta
ematch at egress.

> I see the issue with classid leaking - perhaps specific actions could
> reset it when they steal packets? We should also reset it if the packet
> is stolen.

Definitely.

I'm not yet certain on this subject, I have a strong feeling that
something like tc_classid will be needed but not as in its current
use. Can we postpone this for 1-2 weeks so I can submit my new
ematch patches? This would give us something to use as a basis for
a discussion.
