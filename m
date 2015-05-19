From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
 instances
Date: Tue, 19 May 2015 09:09:11 -0400
Message-ID: <20150519130911.GB20131@madcap2.tricolour.ca>
References: <cover.1429252659.git.rgb@redhat.com>
 <20150515023221.GC965@madcap2.tricolour.ca>
 <CALCETrWzM4+Vs8OVJWBcWJfbR_DRSb+e7SmUyy6CS4sHQaTkRw@mail.gmail.com>
 <9125391.7ZiCneo6Xn@sifl>
 <555711FA.50703@redhat.com>
 <CAHC9VhRKSK9=9qPF3dgALS=x1g3LinNeQvuhNV5TvQ=D7Szuag@mail.gmail.com>
 <87r3qgpol6.fsf@x220.int.ebiederm.org>
 <CAHC9VhQs6pxFC3dvZic5XzuJr1xdJZyPjXdBoipwY3OOkng0ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux API <linux-api@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, linux-audit@redhat.com,
	Al Viro <viro@zeniv.linux.org.uk>,
	Network Development <netdev@vger.kernel.org>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	Eric Paris <eparis@parisplace.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhQs6pxFC3dvZic5XzuJr1xdJZyPjXdBoipwY3OOkng0ng@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/05/16, Paul Moore wrote:
> On Sat, May 16, 2015 at 10:46 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> > Paul Moore <paul@paul-moore.com> writes:
> >> On Sat, May 16, 2015 at 5:46 AM, Daniel J Walsh <dwalsh@redhat.com> wrote:
> >>> On 05/15/2015 05:05 PM, Paul Moore wrote:
> >>>> On Thursday, May 14, 2015 11:23:09 PM Andy Lutomirski wrote:
> >>>>> On Thu, May 14, 2015 at 7:32 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> >>>>>> On 15/05/14, Paul Moore wrote:
> >>>>>>> * Look at our existing audit records to determine which records should
> >>>>>>> have
> >>>>>>> namespace and container ID tokens added.  We may only want to add the
> >>>>>>> additional fields in the case where the namespace/container ID tokens are
> >>>>>>> not the init namespace.
> >>>>>> If we have a record that ties a set of namespace IDs with a container
> >>>>>> ID, then I expect we only need to list the containerID along with auid
> >>>>>> and sessionID.
> >>>>> The problem here is that the kernel has no concept of a "container", and I
> >>>>> don't think it makes any sense to add one just for audit.  "Container" is a
> >>>>> marketing term used by some userspace tools.
> >>>>>
> >>>>> I can imagine that both audit could benefit from a concept of a
> >>>>> namespace *path* that understands nesting (e.g. root/2/5/1 or
> >>>>> something along those lines).  Mapping these to "containers" belongs
> >>>>> in userspace, I think.
> >>>> It might be helpful to climb up a few levels in this thread ...
> >>>>
> >>>> I think we all agree that containers are not a kernel construct.  I further
> >>>> believe that the kernel has no business generating container IDs, those should
> >>>> come from userspace and will likely be different depending on how you define
> >>>> "container".  However, what is less clear to me at this point is how the
> >>>> kernel should handle the setting, reporting, and general management of this
> >>>> container ID token.
> >>>>
> >>> Wouldn't the easiest thing be to just treat add a containerid to the
> >>> process context like auid.
> >>
> >> I believe so.  At least that was the point I was trying to get across
> >> when I first jumped into this thread.
> >
> > It sounds nice but containers are not just a per process construct.
> > Sometimes you might know anamespace but not which process instigated
> > action to happen on that namespace.
> 
> >From an auditing perspective I'm not sure we will ever hit those
> cases; did you have a particular example in mind?

The example that immediately came to mind when I first read Eric's
comment was a packet coming in off a network in a particular network
namespace.  That could narrow it down to a subset of containers based on
which network namespace it inhabits, but since it isn't associated with
a particular task yet (other than a kernel thread) it will not be
possible to select the precise nsproxy, let alone the container.

> paul moore

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
