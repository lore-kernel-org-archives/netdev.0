From: Pavlin Radoslavov <pavlin@icir.org>
Subject: Re: NETLINK upcalls and wireless events
Date: Wed, 24 Mar 2004 04:05:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403241205.i2OC5YRj006290@possum.icir.org>
References: <hadi@cyberus.ca>
Cc: jt@hpl.hp.com, hostap@shmoo.com, netdev@oss.sgi.com, pavlin@icir.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: Message from jamal <hadi@cyberus.ca>
   of "23 Mar 2004 23:52:25 EST." <1080103945.1472.56.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > Checking whether the message contains the IFLA_WIRELESS field is
> > > probably not an option, because I may be compiling the code on a
> > > slightly older Linux box that doesn't have IFLA_WIRELESS defined.
> > > The only solution I have so far is to check whether the message
> > > contains the IFLA_IFNAME field, but this is more like a work-around
> > > rather than a solution. Any suggestions?
> > 
> > 	The method I personally use is that I keep a little database
> > of interfaces (I need it for other reasons). Therefore, I know if the
> > interface is new (not in my database) or already exist (present in my
> > database).
> 
> This is the best way to do it.
> 
> > 	Note that in theory, RtNetlink messages may be lost (due to
> > memory pressure). Also, you won't only get NEWLINK when interface
> > register, but also when interface goes up and down, or when multicast
> > or promiscuous flags are changed. Which mean that in practice you want
> > to be much more clever than what you do now.
> 
> If you maintain a database in userspace the real good check would be
> the ifindex since this would be unique for the device and persistent. 
> The name can be changed. 
> If you already have the ifindex in your database then clearly thats just
> an event announcement.

Good point! I already have a database with all ifindex so the check
will be trivial.
I will try the other suggestions as well.

> Next thing to check would be the state of the flags/changemask to see if
> the admin status changed (eg ifconfig down ).
> And of course whatever the IFLA_* attribs (which are optionaly sent).
> Typically you can catch lost messages in netlink since the socket gets
> its error flag set. You can use that as an event to check for changes.
> 
> > 
> > 	Both methods you suggest would also work. If IFLA_WIRELESS
> > doesn't exist, just define it :
> > -----------------------------
> > #ifndef IFLA_WIRELESS
> > #define IFLA_WIRELESS	(IFLA_MASTER + 1)
> > #endif /* IFLA_WIRELESS */
> > -----------------------------
> > 
> > 	The latest method is to look at both ifi_flags and
> > ifi_change. If ifi_change is 0, it is usually a wireless event (but
> > not always).
> 
> mask should really indicate that something new is in the flags so
> hopefuly it is not being arbitrarily set to 0 to indicate events.
> Not too familiar with IFLA_WIRELESS - but is this a link event or is 
> something conviniently using the link message? What kind of things does
> it announce/configure?

I am not familiar with IFLA_WIRELESS either, so I don't know what
type of event is.

Thanks for all suggestions!
Pavlin
