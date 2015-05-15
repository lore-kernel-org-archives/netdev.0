From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Fri, 15 May 2015 17:01:25 -0400
Message-ID: <2432781.g45S2r75hS@sifl>
References: <cover.1429252659.git.rgb@redhat.com> <12675437.ssZNCck7zG@sifl> <87bnhmbp8e.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Steve Grubb <sgrubb@redhat.com>,
	Richard Guy Briggs <rgb@redhat.com>,
	containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	eparis@parisplace.org, arozansk@redhat.com, serge@hallyn.com,
	zohar@linux.vnet.ibm.com, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bnhmbp8e.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 14, 2015 08:31:45 PM Eric W. Biederman wrote:
> Paul Moore <pmoore@redhat.com> writes:
> > As Eric, and others, have stated, the container concept is a userspace
> > idea, not a kernel idea; the kernel only knows, and cares about,
> > namespaces.  This is unlikely to change.
> > 
> > However, as Steve points out, there is precedence for the kernel to record
> > userspace tokens for the sake of audit.  Personally I'm not a big fan of
> > this in general, but I do recognize that it does satisfy a legitimate
> > need.  Think of things like auid and the sessionid as necessary evils;
> > audit is already chock full of evilness I doubt one more will doom us all
> > to hell.
> > 
> > Moving forward, I'd like to see the following:
> > 
> > * Create a container ID token (unsigned 32-bit integer?), similar to
> > auid/sessionid, that is set by userspace and carried by the kernel to be
> > used in audit records.  I'd like to see some discussion on how we manage
> > this, e.g. how do handle container ID inheritance, how do we handle
> > nested containers (setting the containerid when it is already set), do we
> > care if multiple different containers share the same namespace config,
> > etc.?
> > 
> > 
> > Can we all live with this?  If not, please suggest some alternate ideas;
> > simply shouting "IT'S ALL CRAP!" isn't helpful for anyone ... it may be
> > true, but it doesn't help us solve the problem ;)
> 
> Without stopping and defining what someone means by container I think it
> is pretty much nonsense.

For what it is worth, I doubt we will ever arrive at a consistent definition 
of a container.  This is one of the reasons why I don't think we want the 
kernel generating a container ID token, although I understand the real world 
desire to have the kernel report such information back in the audit logs.

> Should every vsftp connection get a container every?  Every chrome tab?

That's up to the individual system.  I would argue that's a pretty silly 
configuration, but one persons silliness is another's best practice.  It's a 
mad, mad world.

> At some of the connections per second numbers I have seen we might
> exhaust a 32bit number in an hour or two.  Will any of that make sense
> to someone reading the audit logs?

If someone if going to spawn each process in a container then they will need 
to live with the fallout of that decision.

Also, if folks thing 32-bits is too small, we can always do 64-bits, but I 
don't think that was the point you were trying to make (I could be wrong).

> Without considerning that container creation is an unprivileged
> operation I think it is pretty much nonsense.  Do I get to say I am any
> container I want?  That would seem to invalidate the concept of
> userspace setting a container id.
>
> How does any of this interact with setns?  AKA entering a container?

As I said in my email, I think we need some discussion around this; I don't 
pretend to think we have this sorted at this point.  I just want to make sure 
were working towards some common ground instead of shouting the same stuff 
back and forth at each other.

> I will go as far as looking at patches.  If someone comes up with
> a mission statement about what they are actually trying to achieve and a
> mechanism that actually achieves that, and that allows for containers to
> nest we can talk about doing something like that.

I think Steve has posted some requirements that Richard is trying to satisfy 
with these patches; we've also heard from at least one person who is looking 
at how to deploy this in the Real World.  Perhaps in the next round of patches 
Richard can list the requirements in the 0/X patch and describe how they are 
satisfied in the patchset.

Beyond that, and ignoring for a moment the whole "a container is not a 
*thing*" argument, can I assume that the auditing of nested "containers" are 
your main remaining concern at this point?

> But for right now I just hear proposals for things that make no sense
> and can not possibly work.  Not least because it will require modifying
> every program that creates a container and who knows how many of them
> there are.  Especially since you don't need to be root.  Modifying
> /usr/bin/unshare seems a little far out to me.

I think it is very reasonable that there will be some container infrastructure 
tools which would handle this, we're already seeing this happening now; asking 
for minor changes to these infrastructure applications to support container 
auditing doesn't seem like a significant ask to me.  Also, to be perfectly 
clear, if the applications aren't updated it isn't as if they will fail to 
work, it is just that they won't be able to take advantage of the new 
container auditing capabilities.  That seems reasonable to me.

-- 
paul moore
security @ redhat
