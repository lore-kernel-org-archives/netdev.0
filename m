From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level control message
Date: Wed, 04 Sep 2013 00:42:26 -0700
Message-ID: <878uzdf2xp.fsf@xmission.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1378275261-4553-1-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
To: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1378275261-4553-1-git-send-email-jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Jan
	Kaluza's message of "Wed, 4 Sep 2013 08:14:18 +0200")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Hi,
>
> this patchset against net-next (applies also to linux-next) adds 3 new types
> of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).
>
> Server-like processes in many cases need credentials and other
> metadata of the peer, to decide if the calling process is allowed to
> request a specific action, or the server just wants to log away this
> type of information for auditing tasks.
>
> The current practice to retrieve such process metadata is to look that
> information up in procfs with the $PID received over SCM_CREDENTIALS.
> This is sufficient for long-running tasks, but introduces a race which
> cannot be worked around for short-living processes; the calling
> process and all the information in /proc/$PID/ is gone before the
> receiver of the socket message can look it up.

> Changes introduced in this patchset can also increase performance
> of such server-like processes, because current way of opening and
> parsing /proc/$PID/* files is much more expensive than receiving these
> metadata using SCM.

Can I just say ick, blech, barf, gag.

You don't require this information to be passed.  You are asking people
to suport a lot of new code for the forseeable future.  The only advantage
appears to be for short lived racy processes that don't even bother to
make certain their message was acknowleged before exiting.

You sent this during the merge window which is the time for code
integration and testing not new code.

By my count you have overflowed cb in struct sk_buff and are stomping on
_skb_refdest.

If you are going to go crazy and pass things is there a reason you do
not add a patch to pass the bsd SCM_CREDS?  That information seems more
relevant in a security context and for making security decisions than
about half the information you are passing.

Eric
