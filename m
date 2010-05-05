From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/6] netns: Teach network device kobjects which
 namespace they are in.
Date: Wed, 5 May 2010 17:01:50 -0500
Message-ID: <20100505220150.GA11595@us.ibm.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
 <1273019809-16472-2-git-send-email-ebiederm@xmission.com>
 <20100505151746.GA15654@us.ibm.com>
 <m14oim2kcm.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m14oim2kcm.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> diff --git a/net/Kconfig b/net/Kconfig
> >> index 041c35e..265e33b 100644
> >> --- a/net/Kconfig
> >> +++ b/net/Kconfig
> >> @@ -45,6 +45,14 @@ config COMPAT_NETLINK_MESSAGES
> >> 
> >>  menu "Networking options"
> >> 
> >> +config NET_NS
> >> +	bool "Network namespace support"
> >> +	default n
> >> +	depends on EXPERIMENTAL && NAMESPACES
> >> +	help
> >> +	  Allow user space to create what appear to be multiple instances
> >> +	  of the network stack.
> >> +
> >
> > Hi Eric,
> >
> > I'm confused - NET_NS is defined in init/Kconfig right now.  Is the tree
> > you're working from very different from mine, or is this the unfortunate
> > rekult of the patches sitting so long?
> 
> Old patches, nothing that complains when you make a mistake like this,
> and apparently I have a blind spot in my personal code review.

haha, we all know about that.

> At one point it was not possible to enable the network namespace until
> the sysfs stuff was enabled, but things have been going on long enough
> that we worked around that restriction.

Yeah, I remember that, and leaving this wouldn't break anything.

> >>  int netdev_kobject_init(void)
> >>  {
> >> +	kobj_ns_type_register(&net_ns_type_operations);
> >> +#ifdef CONFIG_SYSFS
> >> +	register_pernet_subsys(&sysfs_net_ops);
> >> +#endif
> >>  	return class_register(&net_class);
> >
> > I think the kobj_ns_type_register() needs to be under
> > ifdef CONFIG_SYSFS as well, bc net_ns_type_operations is defined
> > under ifdef CONFIG_SYSFS.
> 
> kobj_ns_type_register should not be under CONFIG_SYSFS.  Which means
> that kobj_ns_type_operations needs not to be under CONFIG_SYSFS as
> well.  That you for spotting that bug.

np - outside of that,

Acked-by: Serge E. Hallyn <serue@us.ibm.com>

I saw no problems with the other patches, just don't feel qualified
to give an ack.

thanks,
-serge
