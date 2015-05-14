From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Thu, 14 May 2015 12:21:53 -0400
Message-ID: <3156096.4s7Ni5U1tG@x2>
References: <cover.1429252659.git.rgb@redhat.com> <2918460.dpKocsKt4o@x2>
	<87iobvnp1t.fsf@x220.int.ebiederm.org>
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
In-Reply-To: <87iobvnp1t.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

On Thursday, May 14, 2015 10:42:38 AM Eric W. Biederman wrote:
> Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > On Tuesday, May 12, 2015 03:57:59 PM Richard Guy Briggs wrote:
> >> On 15/05/05, Steve Grubb wrote:
> >> > I think there needs to be some more discussion around this. It seems
> >> > like
> >> > this is not exactly recording things that are useful for audit.
> >> 
> >> It seems to me that either audit has to assemble that information, or
> >> the kernel has to do so.  The kernel doesn't know about containers
> >> (yet?).
> > 
> > Auditing is something that has a lot of requirements imposed on it by
> > security standards. There was no requirement to have an auid until audit
> > came along and said that uid is not good enough to know who is issuing
> > commands because of su or sudo. There was no requirement for sessionid
> > until we had to track each action back to a login so we could see if the
> > login came from the expected place.
> 
> Stop right there.
> 
> You want a global identifier in a realm where only relative identifiers
> exist, and make sense.

Global to a name space for me is I guess relative for you. The ID is needed to 
tie events together to check for violations of the security policy of the 
container/namespace invoking child container/namespace.

As a concrete example, suppose a container is to have its own /etc/shadow. If 
for some reason the container used the host's copy, then that would point to a 
misconfiguration or perhaps indicate an escape from the container.

I would imagine that the next layer down has its own set of global identifiers 
so that it can verify enforcement of its own security assumptions. This does 
not need to be global to the system from top to 9 layers down. Each layer 
needs to have a way of locating events common to a child container instance.


> I am sorry that isn't going to happen. EVER.

Then I'd suggest we either scrap this set of patches and forget auditing of 
containers. (This would have the effect of disallowing them in a lot of 
environments because violations of security policy can't be detected.)

Or someone please explain how what is proposed to be logged allows the tying 
together of events. Or even supports the requirements I stated in my last 
email. 

-Steve
