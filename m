From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: 08 Mar 2005 17:21:27 -0500
Message-ID: <1110320486.1077.117.camel@jzny.localdomain>
References: <20050305172257.GN31837@postel.suug.ch>
	 <1110202499.1094.1371.camel@jzny.localdomain>
	 <20050307142622.GT31837@postel.suug.ch>
	 <1110240219.1044.83.camel@jzny.localdomain>
	 <20050308013718.GZ31837@postel.suug.ch>
	 <1110290055.1043.183.camel@jzny.localdomain>
	 <20050308142713.GB31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, benjamin.zores@loria.fr
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050308142713.GB31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 09:27, Thomas Graf wrote:
> * jamal <1110290055.1043.183.camel@jzny.localdomain> 2005-03-08 08:54
[..]
> 
> Possibily yes, I'm not quite sure why it would involve a shell at least

Ok, I could be wrong - if you use some xml library that has xslt library
then you should be fine.

> it is quite simple to work around using one but I tend to agree. What I'm
> aiming for is some kind of generic request record format acting as base
> for logging, distribution, whatever purpose and I think that is what you
> mean with the "layer above libnl" so we're probably heading into the same
> direction with minor differences in how to actually do it.
> 

I am thinking API. And the reason i sensed you and the gnome guy had a
good fit was he had this API, it may have to be refined. 

> I'll keep on experimenting with it hoping to present some more detailed
> results soon so we can redraw once we have some prototype and numbers.
> 

makes sense 


> > There is no byte order issues with ASCII.
> 
> Obviously yes, it depends on at which layer the transformation is done
> and that's the point I'm still unsure. The obvious way is to do it in
> the actual module implementations of libnl and have the produced XML
> protocol being aware of every single configuration bit. Another way
> is to describe the actual netlink requests in a half-binary format and
> do the transformation later. The latter saves a lot of transformation
> work because everything in between doesn't need to be aware of all the
> configuration possibilities. However, the transformation to other
> protocol types gets more complicated. I haven't found any arguments
> for either way that would convice me to head for one direction so I
> planned to find out by experimenting.
> 

Well, xml transfered from remote configuration machine.
application takes xml and through some magic layer (either xslt
transform etc) makes a change a call to gnome-dudes API.
Gnome-dude's api calls libnl. libnl calls netlink to kernel.
Since the remote calls terminate at the layer above gnome-dude you
shouldnt have to worry.

> > Yes, i remember that code now. They do use ioctls. 
> > Unfortunately your libnl is not backward compatible and a lot of
> > embedded devices are 2.4.x based. Ive mentioned this before. You need to
> > provide a ioctl interface for some things as well and perhaps provide a
> > compile flag to select between the two.
> 
> Indeed, I'm not sure how to solve this properly though. libnl's scope
> is already quite huge and it might be better to build another layer on
> top of it (maybe the one you mentioned) which abstracts the whole network
> configuration in a nice API automatically doing the right thing (tm)
> by checking kernel capabilities an choose netlink/ioctl/ethtool/...
> or whatever is appropriate.

Well, use netlink at all times. But for sucess you MUST have backward
compatibility. And this may mean a compile config (make config) which
has a selection to use ioctls when they are available (only two i can
really think of in rtnelink that are reklevant are IFLA and IFA).

> > On completion, I thin they had some basic stuff working which is a good
> > start (If i recall they could set ip addresses and routes).
> 
> From what the source tells me, interface and routing has been partially
> implemented which is a nice start. The code could be merged into the
> above mentioned library acting as interface for netconf to interact
> with the kernel.
> 

Well, i think theres a very clean separation. They have a few functions
which convert from XML to add routes etc. Thats the part that needs to
call "api above libnl" which calls libnl IMO.
in other words you are providing these services to them.


> > The problem is i think you are trying to do all layers.
> 
> I'm thinking in all layers to not miss anything important but it should
> definitely be spread across various independant parts.
> 

Understood - I am just saying this is huuge amounts of work; you may
wanna involve the gnome guy and let him worry about "the layer above
libnl". I would be more than happy to participate in the discussions
for what the API should be (many many opinions based on experience)
without necessarily commiting that i will have time to code anything.

cheers,
jamal
