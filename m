From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 16:03:03 +0400
Message-ID: <1222862583.23573.54.camel@iris.sw.ru>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	<48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru>
	<48E3653C.1070701@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48E3653C.1070701-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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

On Wed, 2008-10-01 at 13:55 +0200, Daniel Lezcano wrote:
> Denis V. Lunev wrote:
> > On Wed, 2008-10-01 at 13:13 +0200, Daniel Lezcano wrote:
> >> Denis V. Lunev wrote:
> >>> This patch opens a way to connect via Unix socket from one namespace
> >>> to another if these sockets are opened via conventional filesystem
> >>> interface. Such approach allows to share important services between
> >>> namespaces in efficient way.
> >>>
> >>> This breach is controlled by the means of shared filesystem, i.e. if
> >>> somebody really wants to isolate containers, he should start from
> >>> filesystem separation.
> >>>
> >>> Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> >>> ---
> >>>  net/unix/af_unix.c |    3 ---
> >>>  1 files changed, 0 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> >>> index 39d2173..0e1eccd 100644
> >>> --- a/net/unix/af_unix.c
> >>> +++ b/net/unix/af_unix.c
> >>> @@ -297,9 +297,6 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
> >>>  		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
> >>>  		struct dentry *dentry = unix_sk(s)->dentry;
> >>>
> >>> -		if (!net_eq(sock_net(s), net))
> >>> -			continue;
> >>> -
> >>>  		if(dentry && dentry->d_inode == i)
> >>>  		{
> >>>  			sock_hold(s);
> >> Hi Denis,
> >>
> >> Do you have a list of the important services this isolation forbids ? (I 
> >> suppose there is syslog).
> > 
> > we have asked from our customers for a shared MySQL server
> > 
> > The full story is here :)
> > http://bugzilla.openvz.org/show_bug.cgi?id=985
> 
> Ok, thanks.
> 
> My question remains :)
> 
> How do you handle migration in this case ?

There is no problem until you really have listeners from different
namespaces on both ends. This is checked after the freeze stage and
migration is forbidden if such a situation is detected.
