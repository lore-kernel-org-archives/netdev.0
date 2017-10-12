From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 12 Oct 2017 12:59:57 -0500
Message-ID: <8760bkxn4y.fsf@xmission.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171012141359.saqdtnodwmbz33b2-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org> (Richard
	Guy Briggs's message of "Thu, 12 Oct 2017 10:14:00 -0400")
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

Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> A namespace cannot directly migrate from one container to another but
> could be assigned to a newly spawned container.  A namespace can be
> moved from one container to another indirectly by having that namespace
> used in a second process in another container and then ending all the
> processes in the first container.

Ugh no.  The semantics here are way too mushy.  We need a clean crisp
unambiguous definition or it will be impossible to get this correct and
impossible to use for any security purpose.

I understand the challenge.  Some of the container managers share
namespaces between containers.  Leading to things that are not really
contained.

Please make this concept like an indellibale die.  Once you are stained
with it you can not escape.  If you don't meet all of the criteria you
aren't stained.

The justification that I heard, and that seems legitimate is that it is
not timely and it is hard to make the connection between the distinct
unshare, setns, and clone events and what is happening in the kernel.

With that justification definitely the network namespace needs to be
stained if it is appropriate.

I also don't see why this can't be a special dedicated audit message.
I just looked at the code in the kernel and nlmsg_type is a u16.  There
are only a handful of audit message types defined.  There is absolutely
no reason to bring proc into this.

I have the same reservation as the others about defining a new cap for
this.  It should be enough to make setting the container id a one time
thing for a set of processes and namespaces.

If this is going to be security it needs to be very simple and very well defined.

Eric
