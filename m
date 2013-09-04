From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level
	control message
Date: Wed, 4 Sep 2013 10:58:30 -0400
Message-ID: <20130904145830.GC28517@madcap2.tricolour.ca>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1378275261-4553-1-git-send-email-jkaluza@redhat.com>
	<878uzdf2xp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <878uzdf2xp.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Wed, Sep 04, 2013 at 12:42:26AM -0700, Eric W. Biederman wrote:
> Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > Hi,
> >
> > this patchset against net-next (applies also to linux-next) adds 3 new types
> > of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).
> >
> > Server-like processes in many cases need credentials and other
> > metadata of the peer, to decide if the calling process is allowed to
> > request a specific action, or the server just wants to log away this
> > type of information for auditing tasks.
> >
> > The current practice to retrieve such process metadata is to look that
> > information up in procfs with the $PID received over SCM_CREDENTIALS.
> > This is sufficient for long-running tasks, but introduces a race which
> > cannot be worked around for short-living processes; the calling
> > process and all the information in /proc/$PID/ is gone before the
> > receiver of the socket message can look it up.
> 
> > Changes introduced in this patchset can also increase performance
> > of such server-like processes, because current way of opening and
> > parsing /proc/$PID/* files is much more expensive than receiving these
> > metadata using SCM.
> 
> Can I just say ick, blech, barf, gag.

/me hands ebiederman an air sickness bag.

> You don't require this information to be passed.  You are asking people
> to suport a lot of new code for the forseeable future.  The only advantage
> appears to be for short lived racy processes that don't even bother to
> make certain their message was acknowleged before exiting.
> 
> You sent this during the merge window which is the time for code
> integration and testing not new code.

This is an RFC.  How is this important?

> By my count you have overflowed cb in struct sk_buff and are stomping on
> _skb_refdest.

For patch1/3 I count 56/48, then for patch3 I get 48/48.  Jan, you might
do the conversion to a pointer in patch1/3 to avoid bisect breakage.

> If you are going to go crazy and pass things is there a reason you do
> not add a patch to pass the bsd SCM_CREDS?  That information seems more
> relevant in a security context and for making security decisions than
> about half the information you are passing.
> 
> Eric

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer
Kernel Security
AMER ENG Base Operating Systems
Remote, Ottawa, Canada
Voice: +1.647.777.2635
Internal: (81) 32635
Alt: +1.613.693.0684x3545
