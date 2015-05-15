From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
 instances
Date: Thu, 14 May 2015 22:25:27 -0400
Message-ID: <20150515022527.GB965@madcap2.tricolour.ca>
References: <cover.1429252659.git.rgb@redhat.com>
 <20150512195759.GA9832@madcap2.tricolour.ca>
 <2918460.dpKocsKt4o@x2>
 <12675437.ssZNCck7zG@sifl>
 <87bnhmbp8e.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <pmoore@redhat.com>, Steve Grubb <sgrubb@redhat.com>,
	containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	eparis@parisplace.org, arozansk@redhat.com, serge@hallyn.com,
	zohar@linux.vnet.ibm.com, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423217AbbEOCZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 22:25:31 -0400
Content-Disposition: inline
In-Reply-To: <87bnhmbp8e.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/14, Eric W. Biederman wrote:
> Paul Moore <pmoore@redhat.com> writes:
> > As Eric, and others, have stated, the container concept is a userspace idea, 
> > not a kernel idea; the kernel only knows, and cares about, namespaces.  This 
> > is unlikely to change.
> >
> > However, as Steve points out, there is precedence for the kernel to record 
> > userspace tokens for the sake of audit.  Personally I'm not a big fan of this 
> > in general, but I do recognize that it does satisfy a legitimate need.  Think 
> > of things like auid and the sessionid as necessary evils; audit is already 
> > chock full of evilness I doubt one more will doom us all to hell.
> >
> > Moving forward, I'd like to see the following:
> 
> > * Create a container ID token (unsigned 32-bit integer?), similar to 
> > auid/sessionid, that is set by userspace and carried by the kernel to be used 
> > in audit records.  I'd like to see some discussion on how we manage this, e.g. 
> > how do handle container ID inheritance, how do we handle nested containers 
> > (setting the containerid when it is already set), do we care if multiple 
> > different containers share the same namespace config, etc.?
> 
> 
> > Can we all live with this?  If not, please suggest some alternate ideas; 
> > simply shouting "IT'S ALL CRAP!" isn't helpful for anyone ... it may be true, 
> > but it doesn't help us solve the problem ;)
> 
> Without stopping and defining what someone means by container I think it
> is pretty much nonsense.

Not complete, but this is why I'm asking for a standards document...

> Should every vsftp connection get a container every?  Every chrome tab?
> 
> At some of the connections per second numbers I have seen we might
> exhaust a 32bit number in an hour or two.  Will any of that make sense
> to someone reading the audit logs?

So making it 64bits buys us some time, but sure...  I think your
definition of a container may be a bit more liberal than what we're
trying to understand...

> Without considerning that container creation is an unprivileged
> operation I think it is pretty much nonsense.  Do I get to say I am any
> container I want?  That would seem to invalidate the concept of
> userspace setting a container id.

Ok, my impression was that we're dealing with a privileged application
as I alluded with the need to create a new CAP_AUDIT_CONTAINER_ID or
something...

> How does any of this interact with setns?  AKA entering a container?

You mean entering another namespace that might all be part of one
container?  Or an an application attempting to enter the namespace of
another container?

> I will go as far as looking at patches.  If someone comes up with
> a mission statement about what they are actually trying to achieve and a
> mechanism that actually achieves that, and that allows for containers to
> nest we can talk about doing something like that.

I don't pretend these patches are anywhere near finished or ready for
upstream.

> But for right now I just hear proposals for things that make no sense
> and can not possibly work.  Not least because it will require modifying
> every program that creates a container and who knows how many of them
> there are.  Especially since you don't need to be root.  Modifying
> /usr/bin/unshare seems a little far out to me.

My understanding is that just spawning or changing namespace doesn't
imply spawning or changing containers.  I also don't necessarily assume
that creating a container is an atomic operation, though that concept
might make some sense to understand or predict the boundaries of
actions...

> Eric

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
