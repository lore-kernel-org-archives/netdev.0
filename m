From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 13:45:38 -0300
Message-ID: <20050119134538.J15303@almesberger.net>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106144009.1047.989.camel@jzny.localdomain>; from hadi@cyberus.ca on Wed, Jan 19, 2005 at 09:13:30AM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> As Lennert was saying, puke whatever the kernel said and allow for
> rollback. i.e undo the first one if it succeeded for example.

How about this: you have a shadow configuration tree on each ingress
and egress point (i.e. two per interface). An update generates the
shadow tree. If done, you commit the shadow tree to become the new
config, and then you can quietly dismantle the old config. If you
didn't like the changes, you kill the shadow tree, without committing
it.

To preserve queue content and element state (e.g. policer state),
you'd also have to have a means to tell where to take things from,
e.g. "shadow" qdisc X inherits the packets from "real" qdisc Y. All
this could be checked for consistency at setup time.

There are of course limitations, e.g. when you merge or split flows.

As an optimization, you could have some "lazy copy": instead of
creating new qdisc "inheriting" from some other, you just move it
from the old to the new tree.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
