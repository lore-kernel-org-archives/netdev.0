From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Tue, 10 Dec 2002 00:10:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF52302.D0DBE637@isg.de>
References: <Pine.GSO.4.30.0212090810520.19181-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Jeff Garzik <jgarzik@pobox.com>,
   "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> > My argument is, _after_ Stefan's link state patch is applied, why do we
> > need the additional patch?  [this question is meant to be delivered in
> > an honest, not snide way...]
> >
> 
> I somehow deleted the original email he sent with the patches. What two
> patches? I thought he had one which was a backport and another which
> was for 2.5.x

I've splitted the patch into userspace notification and RFC2863 part to
separate the features clearly and get the discussion running again. That
seem to have worked ;-)

> (sorry, i actually have seen those patches a few times so i
> didnt bother reviewing anything); In any case, when you look at this stuff
> think as well of devices that are software netddevices example VLANs or
> PPP or some of the USB, Irda etc and you want the status properly
> reflected (and some of that status may not make sense to ethernet for
> example).

As an example, how do we flag a sleeping dial on demand device with the
current Linux semantics? Is it oper up, because it may be able to
transmit packets and should be considered, or is it oper down, simply as
no protocol has been negotiated. RFC2863 can provice a clear state:
Dormant.

Beside this, we currently have the situation that we can put a device
into admin up and not present, simply by calling netdev_carrier_on() and
netdev_detach(). I consider that broken, a device cannot be both removed
and ready.

I'm aware that I did not provide updates to drivers to use the new
states, but that's just the nature of infrastructure creating patches.
Also, I cannot forwarding the RFC2863 state to userspace as long as
Alexey refuses space in the netlink message for it.

Ok, IMHO the pro and contra arguments are said. So let's decide: Do we
want RFC2863 semantics (of course yes ;-) and David either accepts the
second part of the patch or I continue working on it, or do we just drop
that part?

Stefan
