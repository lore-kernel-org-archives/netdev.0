From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 16:20:17 +0100
Message-ID: <20050118152017.GA11798@xi.wantstofly.org>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118143658.GA11474@xi.wantstofly.org> <1106059431.1035.101.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106059431.1035.101.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2005 at 09:43:51AM -0500, jamal wrote:

> > If you do this, please consider using Juniper config syntax instead
> > of doing it the Cisco/quagga way.
> 
> Juniper is XML driven config files?

Uhm, no :)  The main advantage over Cisco (IMHO, the last thing I want
is to start a holy war) is hierarchical config syntax, and the ability
to commit/rollback all your changes in one go.  It's unfortunately
rather more verbose, though.  Example at the bottom.


> btw, libio uses libevent; i recall you said you had some alternative to
> it.

Yeah, ivykis (http://libivykis.sourceforge.net/) has been happily used
in-house at my last job for years but never really caught on anywhere
else, which is perhaps because I never did much lobbying for it.  The
way it works also requires all code written for it to be fully async
(can't use blocking code anywhere), which I think is an advantage but
everyone else thinks is a disadvantage.


cheers,
Lennert



This is an example of a Juniper policy-statement, which is basically
just a prefix filter.  This particular filter controls which non-OSPF
prefixes are exported to OSPF.


buytenh@asd-tc2-m20core1> show configuration policy-options policy-statement ospf-export    
term accept-default {
    from {
        route-filter 0.0.0.0/0 exact;
    }
    then {
        external {
            type 1;
        }
        accept;
    }
}
term accept-peering {
    from {
        protocol direct;
        route-filter 0.0.0.0/0 prefix-length-range /30-/30;
    }
    then {
        external {
            type 1;
        }
        accept;
    }
}
term accept-ams-ix {
    from {
        protocol direct;
        route-filter 195.69.144.0/23 exact;
    }
    then {
        external {
            type 1;
        }
        accept;
    }
}
term reject-rest {
    then reject;
}

buytenh@asd-tc2-m20core1> 
