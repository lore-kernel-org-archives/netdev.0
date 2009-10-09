From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: Real networking namespace
Date: Fri, 09 Oct 2009 12:44:52 -0400
Message-ID: <1255106692.2182.224.camel@moss-pluto.epoch.ncsc.mil>
References: <20091009083807.16e55b08@nehalam>
	 <1255106246.2182.219.camel@moss-pluto.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	Al Viro <viro@ZenIV.linux.org.uk>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>,
	James Morris <jmorris@namei.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1255106246.2182.219.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-10-09 at 12:37 -0400, Stephen Smalley wrote:
> On Fri, 2009-10-09 at 08:38 -0700, Stephen Hemminger wrote:
> > The existing networking namespace model is unattractive for what I want,
> > has anyone investigated better alternatives?
> > 
> > I would like to be able to allow access to a network interface and associated objects
> > (routing tables etc), to be controlled by Mandatory Access Control API's.
> > I.e grant access to eth0 and to only certain processes.  Some the issues
> > with the existing models are:
> >   * eth0 and associated objects don't really exist in filesystem so
> >     not subject to LSM style control (SeLinux/SMACK/TOMOYO)
> >   * network namespaces do not allow object to exist in multiple namespaces.
> >     The current model is more restrictive than chroot jails. At least with
> >     chroot, put filesystem objects in multiple jails.
> > 
> > Since one of the first rules of security is "don't reinvent", surely
> > others have dealt with this issue. Any good ideas?
> 
> Is there something that prevents you from using the existing SELinux
> network access controls?  netif is a security class governed by SELinux
> policy, and routing table operations would be covered by the SELinux
> checks on netlink_route_socket.  SELinux uses a combination of LSM hooks
> and netfilter hooks to mediate network operations.

Also, depending on what you want to do, SECMARK may be useful to you.
That allows you to mark packets with security contexts via iptables, and
then use SELinux policy to control their flow.
http://paulmoore.livejournal.com/4281.html
http://james-morris.livejournal.com/11010.html

-- 
Stephen Smalley
National Security Agency

