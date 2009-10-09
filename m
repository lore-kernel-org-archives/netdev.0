From: Paul Moore <paul.moore@hp.com>
Subject: Re: Real networking namespace
Date: Fri, 9 Oct 2009 18:12:15 -0400
Message-ID: <200910091812.16046.paul.moore@hp.com>
References: <20091009083807.16e55b08@nehalam> <1255106246.2182.219.camel@moss-pluto.epoch.ncsc.mil> <1255106692.2182.224.camel@moss-pluto.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-security-module@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1255106692.2182.224.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 October 2009 12:44:52 pm Stephen Smalley wrote:
> On Fri, 2009-10-09 at 12:37 -0400, Stephen Smalley wrote:
> > On Fri, 2009-10-09 at 08:38 -0700, Stephen Hemminger wrote:
> > > The existing networking namespace model is unattractive for what I
> > > want, has anyone investigated better alternatives?
> > >
> > > I would like to be able to allow access to a network interface and
> > > associated objects (routing tables etc), to be controlled by Mandatory
> > > Access Control API's. I.e grant access to eth0 and to only certain
> > > processes.  Some the issues with the existing models are:
> > >   * eth0 and associated objects don't really exist in filesystem so
> > >     not subject to LSM style control (SeLinux/SMACK/TOMOYO)

As Stephen points out, SELinux does have the ability to assign security labels 
to network interfaces, check out the 'semanage' command.  A while back I wrote 
up something about the SELinux network "ingress/egress" access controls:

 * http://paulmoore.livejournal.com/2128.html

Smack doesn't support controlling network access at the interface level, but 
that is due to a Smack design decision and not an inherent functionality gap 
in the LSM.  TOMOYO is currently working on improved network access controls 
(see patches posted earlier this week), I haven't had a chance to review them 
yet so I don't know the state of TOMOYO's network access controls.

> > >   * network namespaces do not allow object to exist in multiple
> > > namespaces. The current model is more restrictive than chroot jails. At
> > > least with chroot, put filesystem objects in multiple jails.

Perhaps I don't fully understand what you are getting at here, but I don't 
think this should be an issue with a flexible LSM.

> > Is there something that prevents you from using the existing SELinux
> > network access controls?  netif is a security class governed by SELinux
> > policy, and routing table operations would be covered by the SELinux
> > checks on netlink_route_socket.  SELinux uses a combination of LSM hooks
> > and netfilter hooks to mediate network operations.
> 
> Also, depending on what you want to do, SECMARK may be useful to you.
> That allows you to mark packets with security contexts via iptables, and
> then use SELinux policy to control their flow.
> http://paulmoore.livejournal.com/4281.html
> http://james-morris.livejournal.com/11010.html

While we're at it, a few more links ... here is a presentation from last year 
on Linux's labeled networking capabilities (which hits at a lot of your 
questions):

 * http://paulmoore.livejournal.com/964.html

... and there is a video too:

 * http://paulmoore.livejournal.com/1329.html

-- 
paul moore
linux @ hp
