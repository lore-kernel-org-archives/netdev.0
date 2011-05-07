From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Sat, 07 May 2011 07:58:28 +0100
Message-ID: <3A54AB469A0294933EAC2257@nimrod.local>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1tyd7p7tq.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



--On 6 May 2011 19:23:29 -0700 "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> 
wrote:

> This patchset addresses the user interface limitations by introducing
> proc files you can open to get file descriptors that keep alive and
> refer to your a tasks namespaces.  Those file descriptors can be passed
> to the new setns system call or the NET_NS_FD argument in netlink
> messages.

This is conceptually very interesting. I am one of those people you
describe with a routing daemon (or more accurately a wrapper around
existing daemons) that does the unshare() and keeps the network
alive. It also has a control socket etc.

You say:
> This addresses three specific problems that can make namespaces hard to
> work with.
> - Namespaces require a dedicated process to pin them in memory.
> - It is not possible to use a namespace unless you are the child
>   of the original creator.
> - Namespaces don't have names that userspace can use to talk about
>   them.

At least for me, the best way to solve the second blob would be to
be able to unshare to an existing namespace. That way I would be able
to run a daemon (without modification) in a pre-existing namespace.
The user interface here would just be an option to 'unshare'. I
don't think your patch allows this, does it? Right now I'm effectively
doing that by causing the pid concerned to fork() and do my bidding,
but that is far from perfect.

As a secondary issue, ever without your patch, it would be really
useful to be able to read from userspace the current network namespace.
(i.e. the pid concerned, or 1 if not unshared). I would like to
simply modify a routing daemon's init script so it doesn't start
if in the host, e.g. at the top:
  [ `cat /proc/.../networknamespace` eq 1 ] && exit 0

-- 
Alex Bligh
