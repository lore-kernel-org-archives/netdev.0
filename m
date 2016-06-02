From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per
	userns
Date: Thu, 2 Jun 2016 09:49:20 +0200
Message-ID: <20160602074920.GG19636@quack2.suse.cz>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<8737ow7vcp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8737ow7vcp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

On Wed 01-06-16 11:00:06, Eric W. Biederman wrote:
> Cc'd the containers list.
> 
> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> 
> > Currently the inotify instances/watches are being accounted in the 
> > user_struct structure. This means that in setups where multiple 
> > users in unprivileged containers map to the same underlying 
> > real user (e.g. user_struct) the inotify limits are going to be 
> > shared as well which can lead to unplesantries. This is a problem 
> > since any user inside any of the containers can potentially exhaust 
> > the instance/watches limit which in turn might prevent certain 
> > services from other containers from starting.
> 
> On a high level this is a bit problematic as it appears to escapes the
> current limits and allows anyone creating a user namespace to have their
> own fresh set of limits.  Given that anyone should be able to create a
> user namespace whenever they feel like escaping limits is a problem.
> That however is solvable.
> 
> A practical question.  What kind of limits are we looking at here?
> 
> Are these loose limits for detecting buggy programs that have gone
> off their rails?
> 
> Are these tight limits to ensure multitasking is possible?

The original motivation for these limits is to limit resource usage.  There
is in-kernel data structure that is associated with each notification mark
you create and we don't want users to be able to DoS the system by creating
too many of them. Thus we limit number of notification marks for each user.
There is also a limit on the number of notification instances - those are
naturally limited by the number of open file descriptors but admin may want
to limit them more...

So cgroups would be probably the best fit for this but I'm not sure whether
it is not an overkill...

								Honza
-- 
Jan Kara <jack-IBi9RG/b67k@public.gmane.org>
SUSE Labs, CR
