From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: 08 Mar 2005 08:54:15 -0500
Message-ID: <1110290055.1043.183.camel@jzny.localdomain>
References: <20050305172257.GN31837@postel.suug.ch>
	 <1110202499.1094.1371.camel@jzny.localdomain>
	 <20050307142622.GT31837@postel.suug.ch>
	 <1110240219.1044.83.camel@jzny.localdomain>
	 <20050308013718.GZ31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050308013718.GZ31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 20:37, Thomas Graf wrote:
> * jamal <1110240219.1044.83.camel@jzny.localdomain> 2005-03-07 19:03

[..]
> Absolutely, I plan to be compatible to as many existing protocols as
> possible. The conceptual idea behind is to add another abstraction
> layer before that protocol and have XSLT do the transformation into
> those protocols.
> 
> The path could look like this:
> 
>     (netlink)  (API/daemon)    (XSLT)
> Kernel  ->  libnl  ->  libnl_XML -> netconf
> 

That or you could have netconf just call libnl_something else (which i
have been trying to emphasize as the "the layer above libnl"). What you 
have above will work fine and i very flexible for netconf and maybe even
for SOAP like activities but will end running in a shell which at some
point will become a bottleneck.

> I left out the byte order issues here because I'm not yet sure how
> to solve them although as stated already, using XSLT would be one
> possible path to follow.
> 

There is no byte order issues with ASCII.

> > I believe there is a open source project which does netconf already;
> > maybe all they need is just your library and xml interface ... I will
> > look it up and send you some pointers. 
> 
> You probably mean Yenca,

Aha, yes - thats the one i saw.

>  I'm looking into it but it uses ioctl for
> configuration and only implements a small subset of the functionality.

Yes, i remember that code now. They do use ioctls. 
Unfortunately your libnl is not backward compatible and a lot of
embedded devices are 2.4.x based. Ive mentioned this before. You need to
provide a ioctl interface for some things as well and perhaps provide a
compile flag to select between the two.
On completion, I thin they had some basic stuff working which is a good
start (If i recall they could set ip addresses and routes). The
architecture seemed pretty sane to me; the whole was in the access to
the kernel configuration - they did something but it appeared weak.
This is where you could help i think.

> I've CC'ed Benjamin Zores which is stated as the author in the source
> files.
> 
> > BTW, what happened in the discussion with the gent who was doing SOAP
> > (or was going to do SOAP?)
> 
> The discussion somewhat stalled but I didn't forget about it. Having
> the above architecture would allow to simply put the XML based
> architecture indepedant change requests into SOAP envelopes and distribute
> them.
> 

Well, the way i see it is like this:

3rdlayer: netconf/someotherapp
secondlayer: "the layer above libnl" 
firstlayer: libnl (netlink level)
layer0: kernel

second layer is where that gents code would have been a good fit. He was
already providing some good APIs, bindings etc. XML could be just one
more binding.
The problem is i think you are trying to do all layers.

cheers,
jamal
