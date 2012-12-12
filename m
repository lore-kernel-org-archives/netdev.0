From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Wed, 12 Dec 2012 12:08:50 -0800
Message-ID: <87obhzkp7x.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com>
	<20121207010355.c809b3f7.akpm@linux-foundation.org>
	<20121207142331.GC4004@sergelap> <50C1FD9D.5020703@parallels.com>
	<87r4n1buuw.fsf@xmission.com> <50C6EDF0.5060108@parallels.com>
	<87txrs30ur.fsf@xmission.com> <50C846C7.5050904@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50C846C7.5050904-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Wed, 12 Dec 2012 12:56:39 +0400")
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


This conversation is really debating the wrong question.

The fundamental question is can we modify the kernel such that
containers don't care about anything that goes into the kernel log.

The fundamental question leads to the question what functionality
that is logged to the kernel log must we see in containers.

Serge has a collected a lot of cases and it seems reasonable to assume
that we will find those cases that must show up in a container or
require huge userspace reworking.

These messages that must show up in a container (or break userspace) are
messages that already exist today.  These messages quite likely are
specific to the container itself and I don't think we will need to
double log them.


But the first step of the process is to find the kernel messages that if
we don't log to user space via the kernel log will break user space.

Once we have found those messages and the cases in which there are no
work-arounds we can refine the design with nice to haves.

But this conversation really needs to be about which messages must we
deliver to userspace via the kernel log.


There are a lot of nice to haves messages out there.  Mount failures,
selinux failures etc.  Some of those have a pretty compelling case to be
double logged.

I think for the compelling cases we won't want to doulbe log them, and
those compelling cases need to drive the design.



The most compelling case I know of are firewall log messages that are
logge by explicit user request when selected packets hit the local
firewall.  Those messages I definitely don't want to double log and
those messages are most definitely not interesting to the operator of
the machine.  Those messages are only interesting to the admin who
configured his firewall to log them.

We should look to see if there are alternatives to user configured
firewall log messages that a system administratrator can use.  If not we
have our first compelling case for this functionality.

Eric
