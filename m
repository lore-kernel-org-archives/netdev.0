From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: Tue, 8 Mar 2005 15:27:13 +0100
Message-ID: <20050308142713.GB31837@postel.suug.ch>
References: <20050305172257.GN31837@postel.suug.ch> <1110202499.1094.1371.camel@jzny.localdomain> <20050307142622.GT31837@postel.suug.ch> <1110240219.1044.83.camel@jzny.localdomain> <20050308013718.GZ31837@postel.suug.ch> <1110290055.1043.183.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, benjamin.zores@loria.fr
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110290055.1043.183.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1110290055.1043.183.camel@jzny.localdomain> 2005-03-08 08:54
> On Mon, 2005-03-07 at 20:37, Thomas Graf wrote:
> 
> [..]
> > The path could look like this:
> > 
> >     (netlink)  (API/daemon)    (XSLT)
> > Kernel  ->  libnl  ->  libnl_XML -> netconf
> > 
> 
> That or you could have netconf just call libnl_something else (which i
> have been trying to emphasize as the "the layer above libnl"). What you 
> have above will work fine and i very flexible for netconf and maybe even
> for SOAP like activities but will end running in a shell which at some
> point will become a bottleneck.

Possibily yes, I'm not quite sure why it would involve a shell at least
it is quite simple to work around using one but I tend to agree. What I'm
aiming for is some kind of generic request record format acting as base
for logging, distribution, whatever purpose and I think that is what you
mean with the "layer above libnl" so we're probably heading into the same
direction with minor differences in how to actually do it.

I'll keep on experimenting with it hoping to present some more detailed
results soon so we can redraw once we have some prototype and numbers.

> > I left out the byte order issues here because I'm not yet sure how
> > to solve them although as stated already, using XSLT would be one
> > possible path to follow.
> > 
> 
> There is no byte order issues with ASCII.

Obviously yes, it depends on at which layer the transformation is done
and that's the point I'm still unsure. The obvious way is to do it in
the actual module implementations of libnl and have the produced XML
protocol being aware of every single configuration bit. Another way
is to describe the actual netlink requests in a half-binary format and
do the transformation later. The latter saves a lot of transformation
work because everything in between doesn't need to be aware of all the
configuration possibilities. However, the transformation to other
protocol types gets more complicated. I haven't found any arguments
for either way that would convice me to head for one direction so I
planned to find out by experimenting.

> > You probably mean Yenca,
> [..]
> >  I'm looking into it but it uses ioctl for
> > configuration and only implements a small subset of the functionality.
> 
> Yes, i remember that code now. They do use ioctls. 
> Unfortunately your libnl is not backward compatible and a lot of
> embedded devices are 2.4.x based. Ive mentioned this before. You need to
> provide a ioctl interface for some things as well and perhaps provide a
> compile flag to select between the two.

Indeed, I'm not sure how to solve this properly though. libnl's scope
is already quite huge and it might be better to build another layer on
top of it (maybe the one you mentioned) which abstracts the whole network
configuration in a nice API automatically doing the right thing (tm)
by checking kernel capabilities an choose netlink/ioctl/ethtool/...
or whatever is appropriate.

> On completion, I thin they had some basic stuff working which is a good
> start (If i recall they could set ip addresses and routes).

>From what the source tells me, interface and routing has been partially
implemented which is a nice start. The code could be merged into the
above mentioned library acting as interface for netconf to interact
with the kernel.

> The architecture seemed pretty sane to me; the whole was in the access to
> the kernel configuration - they did something but it appeared weak.
> This is where you could help i think.

I'll try to work this out with Benjamin given it is in his interest.

> Well, the way i see it is like this:
> 
> 3rdlayer: netconf/someotherapp
> secondlayer: "the layer above libnl" 
> firstlayer: libnl (netlink level)
> layer0: kernel
> 
> second layer is where that gents code would have been a good fit. He was
> already providing some good APIs, bindings etc. XML could be just one
> more binding.

Agreed.

> The problem is i think you are trying to do all layers.

I'm thinking in all layers to not miss anything important but it should
definitely be spread across various independant parts.
