From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Fri, 27 May 2005 21:42:46 -0400
Message-ID: <1117244567.6251.34.camel@localhost.localdomain>
References: <20050526185306.GW15391@postel.suug.ch>
	 <20050526185526.GZ15391@postel.suug.ch>
	 <1117192464.6688.3.camel@localhost.localdomain>
	 <20050527121503.GN15391@postel.suug.ch>
	 <1117201853.6383.29.camel@localhost.localdomain>
	 <20050527141023.GP15391@postel.suug.ch>
	 <1117205822.6383.68.camel@localhost.localdomain>
	 <20050527151608.GZ15391@postel.suug.ch>
	 <1117209411.6383.104.camel@localhost.localdomain>
	 <20050527163516.GB15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527163516.GB15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 18:35 +0200, Thomas Graf wrote:

> I do NOT agree on moving gc_ into this architecture as well,
> it doesn't belong there.

Well, you do realize they are part of the in_dev ? ;->

> Nitpicking for a bit, although inet6_dev and in_device hold
> reference to the their arp respectively ndisc parameter set,
> the sysctl interface does not use this reference but stores
> the ifindex of the netdevice, _which_ is correct I think
> because parameter sets are _not_ limited to inetdevs in terms
> of architecture but only in terms of current use.
> 

I see a little main service header with ifindex always no different than
IFA or IFLINK etc followed by appropriate TLVs which are nested.

Unfortunately i still cant find the patch - i started with a different
approach; my immediate interest was to get events when someone made 
in_device changes. BTW, this is going to be one of the main challenges
since there are many paths to configure these things.

> > The deafult can be overriden by devX. So they dont need to sync.
> > But this is a separate topic
> 
> I was not talking about in-sync but rather that gc_* only
> appears in default/ but not in devX/. What I expect is that
> every default parameter can be overwritten in devX which
> is not true for gc_*. Which is the reason why I implemented
> them outside of the NDTPA_PARMS nested TLV.
> 

Well, if you look at the structure there is no reason they should really
be separate; infact theres a comment:
-----------
         struct neigh_parms      parms;
        /* HACK. gc_* shoul follow parms without a gap! */
        int                     gc_interval;
        int                     gc_thresh1;
        int                     gc_thresh2;
----------

To me the abstraction is pretty clear. I would agree that the way
parameters configurable from user space and some of the methods may not
be the best in terms of neighbor tables organization.


> I understand your architecture and if we follow this thought
> we'd have a "default" netdevice which repesents all default
> settings. 

>From looking at the code, the default stuff seems to be "hardcoded".
Example in the definition arp_tbl.

> I do agree with this architecture but the problematic
> question remains: Do we want parameters in "default" which are
> not available in devX? I think this question is what it gets
> down to in the end. If we say, yes we do want this, then we
> can implement all generic settings, such as tcp_, using this
> scheme as well. I don't disagree with this completely but I
> find it not very intuitive from a user perspective.

The model like i said is clean. There are some issues i have qualms with
- such as IP address arrangements and tight integration with netdevices
- but those can addressed at a later time.

cheers,
jamal
