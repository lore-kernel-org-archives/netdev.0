From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Fri, 15 May 2015 06:17:31 -0700
Message-ID: <CALCETrVb0J8JgxOgKi1cR2jfRBU5f7SVe9hQb4GMrMvjwWxDOQ@mail.gmail.com>
References: <cover.1429252659.git.rgb@redhat.com>
	<20150515023221.GC965@madcap2.tricolour.ca>
	<CALCETrWzM4+Vs8OVJWBcWJfbR_DRSb+e7SmUyy6CS4sHQaTkRw@mail.gmail.com>
	<4153072.0EnVzNaVVH@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4153072.0EnVzNaVVH@x2>
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

On May 15, 2015 9:38 PM, "Steve Grubb" <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> On Thursday, May 14, 2015 11:23:09 PM Andy Lutomirski wrote:
> > On Thu, May 14, 2015 at 7:32 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On 15/05/14, Paul Moore wrote:
> > >> * Look at our existing audit records to determine which records should
> > >> have
> > >> namespace and container ID tokens added.  We may only want to add the
> > >> additional fields in the case where the namespace/container ID tokens are
> > >> not the init namespace.
> > >
> > > If we have a record that ties a set of namespace IDs with a container
> > > ID, then I expect we only need to list the containerID along with auid
> > > and sessionID.
> >
> > The problem here is that the kernel has no concept of a "container", and I
> > don't think it makes any sense to add one just for audit.  "Container" is a
> > marketing term used by some userspace tools.
>
> No, its a real thing just like a login. Does the kernel have any concept of a
> login? Yet it happens. And it causes us to generate events describing who,
> where from, role, success, and time of day. :-)
>

I really hope those records come from userspace, not the kernel.  I
also wonder what happens when a user logs in and types "sudo agetty
/dev/ttyS0 115200".  If a user does that and then someone logs in on
/dev/ttyS0, which login are they?

>
> > I can imagine that both audit could benefit from a concept of a
> > namespace *path* that understands nesting (e.g. root/2/5/1 or
> > something along those lines).  Mapping these to "containers" belongs
> > in userspace, I think.
>
> I don't doubt that just as user space sequences the actions that are a login.
> I just need the kernel to do some book keeping and associate the necessary
> attributes in the event record to be able to reconstruct what is actually
> happening.

A precondition for that is having those records have some
correspondence to what is actually happening.  Since the kernel has no
concept of a container, and since the same kernel mechanisms could be
used for things that are probably not whatever the Common Criteria
rules think a container is, this could be quite difficult to define in
a meaningful manner.

Hence my suggestion to add only minimal support in the kernel and to
do this in userspace.

--Andy
