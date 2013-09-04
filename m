From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level
	control message
Date: Wed, 4 Sep 2013 10:45:07 -0400
Message-ID: <20130904144507.GA25788@mtj.dyndns.org>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1378275261-4553-1-git-send-email-jkaluza@redhat.com>
	<878uzdf2xp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
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

Hello, Eric.

On Wed, Sep 04, 2013 at 12:42:26AM -0700, Eric W. Biederman wrote:
> Can I just say ick, blech, barf, gag.

Gees, an awesome way to start the conversation.  If your gag response
is hyper-sensitive, go see a frigging doctor.  It's annoying because
you tend to go over the top while getting things wrong often enough.
Even if you don't agree, you don't have to start things this way.

> You don't require this information to be passed.  You are asking people
> to suport a lot of new code for the forseeable future.  The only advantage
> appears to be for short lived racy processes that don't even bother to
> make certain their message was acknowleged before exiting.

While I'm not sure whether this is *the* right appraoch, how is "we
have some pretty visible race conditions but it's probably okay" an
answer?  This affects auditing and logging directly and you're saying
"ah well, the program wasn't running long enough"?

> You sent this during the merge window which is the time for code
> integration and testing not new code.

What are you talking about?  It is *okay* to send new patches during
merge window even if it's headed for the next merge window.  Sending
patches to maintainers doesn't mean "this should go in right now".
Maintainers are of course free to delay response or ask for
pinging/resending later but it's just stupid to accuse patch
submitters for sending patches.  What the hell is that?

> By my count you have overflowed cb in struct sk_buff and are stomping on
> _skb_refdest.
> 
> If you are going to go crazy and pass things is there a reason you do
> not add a patch to pass the bsd SCM_CREDS?  That information seems more
> relevant in a security context and for making security decisions than
> about half the information you are passing.

You could have lost all the other paragraphs and just responded with
the above.  I don't think we can extend an existing struct but maybe
how information is packed can be adjusted.  That said, the proposed
split makes sense to me.

Thanks.

-- 
tejun
