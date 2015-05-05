From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 05 May 2015 11:16:56 -0400
Message-ID: <1782736.jR73a0QWZa@x2>
References: <cover.1429252659.git.rgb@redhat.com> <2487286.y6vyJ9A3er@x2>
	<87pp6fhy4c.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pp6fhy4c.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

On Tuesday, May 05, 2015 09:56:03 AM Eric W. Biederman wrote:
> Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > The requirements for auditing of containers should be derived from VPP. In
> > it, it asks for selectable auditing, selective audit, and selective audit
> > review. What this means is that we need the container and all its
> > children to have one identifier that is inserted into all the events that
> > are associated with the container.
> 
> That is technically impossible.  Nested containers exist.

OK, then lets talk about that, too. When something is 2 layers deep, the 
outside world cannot make sense of it. The inner one can be a loopback mounted 
file in the outer one. That means that I need the container itself to be 
responsible for events so that things are recorded using paths, uids, and pids 
that make sense to it. It can enrich the events and send them to the outer 
container.


> That is when container G is nested in container F which is in turn
> nested in container E which is in turn nested in container D which is in
> turn nested in container C which is in turn nested in container B which
> is nested in container A there is no one label you can put on audit
> messages from container G which is the ``correct'' one.
> 
> Or are you proposing that something in container G have labels
> A B C D E F G included on every audit message?

We need to have audit events to either be globally tagged so that the outside 
world understand what happening no matter how deep. Or we need each layer to 
be responsible for itself. This means having an audit rule match engine for 
each namespace like netfilter is to networking.


> That introduces enough complexity in generating and parsing the messages I
> wouldn't trust those messages as the least bug in generation and parsing
> would be a security issue.

That goes with the territory.


> What is the world is VPP?

Virtualization Protection Profile. Before people say it doesn't apply, it kind 
of does. It defines the necessary security mechanisms for either full blown 
virt like QEMU/Xen based or it gives enough wiggle room for containers and 
other types of VMs. Specifically, it defines the audit requirements needed for 
this kind of technology.


> It sounds like something non-public thing. Certainly it has never been a
> part of the public container discussion and as such it appears to be
> completely ridiculous to bring up in a public discussion.

No, its a public thing. Audit requirements start in section 5.2:

https://www.niap-ccevs.org/pp/PP_SV_V1.0/

-Steve
