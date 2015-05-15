From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Fri, 15 May 2015 09:51:09 -0500
Message-ID: <87iobtyjvm.fsf@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com> <12675437.ssZNCck7zG@sifl>
	<87bnhmbp8e.fsf@x220.int.ebiederm.org> <2519397.QJshNan19e@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2519397.QJshNan19e@x2> (Steve Grubb's message of "Fri, 15 May
	2015 09:17:24 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Thursday, May 14, 2015 08:31:45 PM Eric W. Biederman wrote:
>> Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> > As Eric, and others, have stated, the container concept is a userspace
>> > idea, not a kernel idea; the kernel only knows, and cares about,
>> > namespaces.  This is unlikely to change.
>> > 
>> > However, as Steve points out, there is precedence for the kernel to record
>> > userspace tokens for the sake of audit.  Personally I'm not a big fan of
>> > this in general, but I do recognize that it does satisfy a legitimate
>> > need.  Think of things like auid and the sessionid as necessary evils;
>> > audit is already chock full of evilness I doubt one more will doom us all
>> > to hell.
>> > 
>> > Moving forward, I'd like to see the following:
>> > 
>> > * Create a container ID token (unsigned 32-bit integer?), similar to
>> > auid/sessionid, that is set by userspace and carried by the kernel to be
>> > used in audit records.  I'd like to see some discussion on how we manage
>> > this, e.g. how do handle container ID inheritance, how do we handle
>> > nested containers (setting the containerid when it is already set), do we
>> > care if multiple different containers share the same namespace config,
>> > etc.?
>> > 
>> > Can we all live with this?  If not, please suggest some alternate ideas;
>> > simply shouting "IT'S ALL CRAP!" isn't helpful for anyone ... it may be
>> > true, but it doesn't help us solve the problem ;)
>> 
>> Without stopping and defining what someone means by container I think it
>> is pretty much nonsense.
>
> Maybe this is what's hanging everyone up? Its easy to get lost when your view 
> is down at the syscall level and what is happening in the kernel. Starting a 
> container is akin to the idea of login. Not every call to setresuid is a 
> login. It could be a setuid program starting or a daemon dropping privileges. 
> The idea of a container is a higher level concept that starting a name space. 
> I think comparing a login with a container is a useful analogy because both 
> are higher level concepts but employ low level ideas. A login is a collection 
> of chdir, setuid, setgid, allocating a tty, associating the first 3 file 
> descriptors, setting a process group, and starting a specific executable. All 
> these low level concepts each by itself is not special.

Except login and setresuid are privileged operation.

CREATING A CONTAINER IS NOT A PRIVILGED OPERATION.
Your analagy fails rather badly with respect to that fact.

> A container is what we need auditing events around not creation of namespaces. 
> If we want creation of namespaces, we can audit the clone/unshare/setns 
> syscalls. The container is when a managing program such as docker, lxc, or 
> sometimes systemd creates a special operating environment for the express 
> purpose of running programs disassociated in some way from the parent 
> namespaces, cgroups, and security assumptions. Its this orchestration, just as 
> sshd orchestrates a login, that makes it different.

What do you define as a container?  From what I can tell we share
a similiar understanding of the term, and running lxc is not a
privileged operation.  Running sandstorm.io is not a privileged
operation.

>> Should every vsftp connection get a container every?  Every chrome tab?
>
> No. Also, note that not every program that grants a user session constitutes a 
> login.

>> At some of the connections per second numbers I have seen we might
>> exhaust a 32bit number in an hour or two.  Will any of that make sense
>> to someone reading the audit logs?
>
> I would agree if we were auditing creation of name spaces. But going back to 
> the concept of login, these could occur at a high rate. This is a bruteforce 
> login attack. We put countermeasures in place to prevent it. But it is 
> possible for the session id to wrap. But in our case, things like lxc or 
> docker don't start hundreds of these a minute.

Except there are reasonable situtations where container creation does
happen at fast rates.  Outside of a container per network connection
(which is likely to happen at some point) I have seen builds fire up
more containers than I can count as part of automated testing.

>> Without considerning that container creation is an unprivileged
>> operation I think it is pretty much nonsense.  Do I get to say I am any
>> container I want?  That would seem to invalidate the concept of
>> userspace setting a container id.
>
> It would need to be a privileged operation just as setuid is.

CONTAINER CREATION IS NOT A PRIVILEGED OPERATION.

That is today.  That is talking about lxc.

CONTAINER CREATION IS NOT A PRIVILEGED OPERATION.

And ultimately we don't want it to be, as if you can safely create a
container without privilege your system is safer.

>> How does any of this interact with setns?  AKA entering a container?
>
> We have to audit this. For the moment, auditing the setns syscall may be 
> enough. I'd have to look at the lifecycle of the application that's doing this 
> to determine if we need more.

Frequently it will be sysadmins for some arbitrary reason calling
nsenter or a similar program that is more aware of their favorite
container flavor.

>> I will go as far as looking at patches.  If someone comes up with
>> a mission statement about what they are actually trying to achieve and a
>> mechanism that actually achieves that, and that allows for containers to
>> nest we can talk about doing something like that.
>
> Auditing wouldn't impose any restrictions on this. We just need a way to 
> observe actions within and associate them as needed to investigate violations 
> of security policy.

*Rolls eyes*  But the rest of the container tool kit in the kernel will
impose limitations on those identifiers.

>> But for right now I just hear proposals for things that make no sense
>> and can not possibly work.  Not least because it will require modifying
>> every program that creates a container and who knows how many of them
>> there are.
>
> We only care about a couple programs doing the orchestration. They will need 
> to have the right support added to them. I'm hoping the analogy of a login 
> helps demonstrate what we are after.

All I see is that (a) you have not defined what you see a container as
(b) you have failed to acknowledge I can create a container without
privilege (which breaks your analogy with login).

But I think I am with Andy.  If you only care about privileged events
and privileged containers, it is unlikely you need to do anything in the
kernel and you can perform whatever logging you see fit in your
privileged userspace applications.

Of course in the log run I don't see what good that will do you as I
expect increasingly there will not need to be any special permissions to
create containers.

Eric
