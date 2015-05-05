From: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 5 May 2015 10:31:20 -0400
Message-ID: <20150505143119.GA4350@redhat.com>
References: <cover.1429252659.git.rgb@redhat.com>
	<11270b0b1afd0a25b108915673e1e1b38dfeeafa.1429252659.git.rgb@redhat.com>
	<2487286.y6vyJ9A3er@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2487286.y6vyJ9A3er@x2>
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

Hi Steve,
On Tue, May 05, 2015 at 10:22:32AM -0400, Steve Grubb wrote:
> The requirements for auditing of containers should be derived from VPP. In it, 
> it asks for selectable auditing, selective audit, and selective audit review. 
> What this means is that we need the container and all its children to have one 
> identifier that is inserted into all the events that are associated with the 
> container.
> 
> With this, its possible to do a search for all events related to a container. 
> Its possible to exclude events from a container. Its possible to not get any 
> events.
> 
> The requirements also call out for the identification of the subject. This 
> means that the event should be bound to a syscall such as clone, setns, or 
> unshare.
> 
> Also, any user space events originating inside the container needs to have the 
> container ID added to the user space event - just like auid and session id.
> 
> Recording each instance of a name space is giving me something that I cannot 
> use to do queries required by the security target. Given these events, how do 
> I locate a web server event where it accesses a watched file? That 
> authentication failed? That an update within the container failed?
> 
> The requirements are that we have to log the creation, suspension, migration, 
> and termination of a container. The requirements are not on the individual 
> name space.
> 
> Maybe I'm missing how these events give me that. But I'd like to hear how I 
> would be able to meet requirements with these 12 events.

what about cases you don't use lxc, libvirt to create namespaces? It's
easier if the logging is done by namespaces and in case they're created
by any container manager, it can generate a new event notifying it
created a container named "foo" with these namespaces: x, y, z, w and
from that you can piece together everything that happened. Userspace
tools can change to adapt to using namespaces and the idea of container
to make it easier to lookup for events instead of relying on a number
that might not be there (think someone using unshare, ip netns, ...). It
was discussed in the past and having the concept of "container" in
kernel space and it's not going to happen, so userspace should deal with
it.

-- 
Aristeu
