From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Fri, 7 Dec 2012 08:23:31 -0600
Message-ID: <20121207142331.GC4004@sergelap>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com>
	<20121207010355.c809b3f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121207010355.c809b3f7.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Mon, 19 Nov 2012 01:51:09 -0800 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:
> 
> > Are there any kernel print statements besides networking stack printks
> > that we want to move to show up in a new "kernel log" namespace?
> 
> That's a good question, and afaict it remains unanswered.

There are some other (not *terribly* compelling) cases.  For instance
selinux hooks, if you say mount an fs without xattr support or with
unsupported options, will printk a warning.  Things like stat.c and
capabilities and syslog print out warnings when userspace uses a
deprecated somethingorother - old stat syscall or sys_syslog without
CAP_SYSLOG.  That should go to the container.  Filesystems may give
warnings (bad mount options for tmpfs, bad uid owner for many of them,
etc) which belong in the container.  Obviously some belong on the host -
if they show a corrupt superblock which may indicate an attempt by the
container to crash the kernel.

> As so often happens, this patchset's changelogs forgot to describe the
> reason for the existence of this patchset.  Via a bit of lwn reading

Not as a separate justification admittedly, but the description was
meant to explain it:  right now /dev/kmsg and sys_syslog are not safe
and useful in a container;  syslog messages from host and containers
can be confusingly intermixed;  and helpful printks are not seen in
the container.

> and my awesome telepathic skills, I divine that something in networking
> is using syslog for kernel->userspace communications.
> 
> wtf?

Well, syslog is the kernel->userspace channel of last resort.

> Wouldn't it be better to just stop doing that, and to implement a
> respectable and reliable kernel->userspace messaging scheme?

Convenience functions on top of netlink?

> And leave syslog alone - it's a crude low-level thing for random
> unexpected things which operators might want to know about.

That sentence is a result of not calling a container admin an operator.
I can't argue it because I'm not sure whether to agree with that
classification.

-serge
