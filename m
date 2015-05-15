From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Thu, 14 May 2015 20:31:45 -0500
Message-ID: <87bnhmbp8e.fsf@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com>
	<20150512195759.GA9832@madcap2.tricolour.ca> <2918460.dpKocsKt4o@x2>
	<12675437.ssZNCck7zG@sifl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org,
	zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <12675437.ssZNCck7zG@sifl> (Paul Moore's message of "Thu, 14 May
	2015 15:19:33 -0400")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> As Eric, and others, have stated, the container concept is a userspace idea, 
> not a kernel idea; the kernel only knows, and cares about, namespaces.  This 
> is unlikely to change.
>
> However, as Steve points out, there is precedence for the kernel to record 
> userspace tokens for the sake of audit.  Personally I'm not a big fan of this 
> in general, but I do recognize that it does satisfy a legitimate need.  Think 
> of things like auid and the sessionid as necessary evils; audit is already 
> chock full of evilness I doubt one more will doom us all to hell.
>
> Moving forward, I'd like to see the following:

> * Create a container ID token (unsigned 32-bit integer?), similar to 
> auid/sessionid, that is set by userspace and carried by the kernel to be used 
> in audit records.  I'd like to see some discussion on how we manage this, e.g. 
> how do handle container ID inheritance, how do we handle nested containers 
> (setting the containerid when it is already set), do we care if multiple 
> different containers share the same namespace config, etc.?


> Can we all live with this?  If not, please suggest some alternate ideas; 
> simply shouting "IT'S ALL CRAP!" isn't helpful for anyone ... it may be true, 
> but it doesn't help us solve the problem ;)

Without stopping and defining what someone means by container I think it
is pretty much nonsense.

Should every vsftp connection get a container every?  Every chrome tab?

At some of the connections per second numbers I have seen we might
exhaust a 32bit number in an hour or two.  Will any of that make sense
to someone reading the audit logs?

Without considerning that container creation is an unprivileged
operation I think it is pretty much nonsense.  Do I get to say I am any
container I want?  That would seem to invalidate the concept of
userspace setting a container id.

How does any of this interact with setns?  AKA entering a container?

I will go as far as looking at patches.  If someone comes up with
a mission statement about what they are actually trying to achieve and a
mechanism that actually achieves that, and that allows for containers to
nest we can talk about doing something like that.

But for right now I just hear proposals for things that make no sense
and can not possibly work.  Not least because it will require modifying
every program that creates a container and who knows how many of them
there are.  Especially since you don't need to be root.  Modifying
/usr/bin/unshare seems a little far out to me.

Eric
