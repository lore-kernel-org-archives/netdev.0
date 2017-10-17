From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Mon, 16 Oct 2017 21:42:52 -0400
Message-ID: <2319693.5l3M4ZINGd@x2>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
	<20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171017003340.whjdkqmkw4lydwy7-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
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

On Monday, October 16, 2017 8:33:40 PM EDT Richard Guy Briggs wrote:
> On 2017-10-12 16:33, Casey Schaufler wrote:
> > On 10/12/2017 7:14 AM, Richard Guy Briggs wrote:
> > > Containers are a userspace concept.  The kernel knows nothing of them.
> > > 
> > > The Linux audit system needs a way to be able to track the container
> > > provenance of events and actions.  Audit needs the kernel's help to do
> > > this.
> > > 
> > > Since the concept of a container is entirely a userspace concept, a
> > > registration from the userspace container orchestration system initiates
> > > this.  This will define a point in time and a set of resources
> > > associated with a particular container with an audit container ID.
> > > 
> > > The registration is a pseudo filesystem (proc, since PID tree already
> > > exists) write of a u8[16] UUID representing the container ID to a file
> > > representing a process that will become the first process in a new
> > > container.  This write might place restrictions on mount namespaces
> > > required to define a container, or at least careful checking of
> > > namespaces in the kernel to verify permissions of the orchestrator so it
> > > can't change its own container ID.  A bind mount of nsfs may be
> > > necessary in the container orchestrator's mntNS.
> > > Note: Use a 128-bit scalar rather than a string to make compares faster
> > > and simpler.
> > > 
> > > Require a new CAP_CONTAINER_ADMIN to be able to carry out the
> > > registration.
> > 
> > Hang on. If containers are a user space concept, how can
> > you want CAP_CONTAINER_ANYTHING? If there's not such thing as
> > a container, how can you be asking for a capability to manage
> > them?
> 
> There is such a thing, but the kernel doesn't know about it yet.  This
> same situation exists for loginuid and sessionid which are userspace
> concepts that the kernel tracks for the convenience of userspace.  As
> for its name, I'm not particularly picky, so if you don't like
> CAP_CONTAINER_* then I'm fine with CAP_AUDIT_CONTAINERID.  It really
> needs to be distinct from CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we
> don't want to give the ability to set a containerID to any process that
> is able to do audit logging (such as vsftpd) and similarly we don't want
> to give the orchestrator the ability to control the setup of the audit
> daemon.

A long time ago, we were debating what should guard against rouge processes 
from setting the loginuid. Casey argued that the ability to set the loginuid 
means they have the ability to control the audit trail. That means that it 
should be guarded by CAP_AUDIT_CONTROL. I think the same logic applies today. 

The ability to arbitrarily set a container ID means the process has the 
ability to indirectly control the audit trail.

-Steve
