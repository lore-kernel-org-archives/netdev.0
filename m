From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 08:44:51 -0700
Message-ID: <1508255091.3129.27.camel@HansenPartnership.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
         <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
         <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
         <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
         <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
         <1508254120.6230.34.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508254120.6230.34.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-17 at 11:28 -0400, Simo Sorce wrote:
> > Without a *kernel* policy on containerIDs you can't say what
> > security policy is being exempted.
> 
> The policy has been basically stated earlier.
> 
> A way to track a set of processes from a specific point in time
> forward. The name used is "container id", but it could be anything.
> This marker is mostly used by user space to track process hierarchies
> without races, these processes can be very privileged, and must not
> be allowed to change the marker themselves when granted the current
> common capabilities.
> 
> Is this a good enough description ? If not can you clarify your
> expectations ?

I think you mean you want to be able to apply a label to a process
which is inherited across forks.  The label should only be susceptible
to modification by something possessing a capability (which one TBD).
 The idea is that processes spawned into a container would be labelled
by the container orchestration system.  It's unclear what should happen
to processes using nsenter after the fact, but policy for that should
be up to the orchestration system.

The label will be used as a tag for audit information.

I think you were missing label inheritance above.

The security implications are that anything that can change the label
could also hide itself and its doings from the audit system and thus
would be used as a means to evade detection.  I actually think this
means the label should be write once (once you've set it, you can't
change it) and orchestration systems should begin as unlabelled
processes allowing them to do arbitrary forks.

For nested containers, I actually think the label should be
hierarchical, so you can add a label for the new nested container but
it still also contains its parents label as well.

James
