From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: limit a number of namespaces which can be cleaned
	up concurrently
Date: Fri, 14 Oct 2016 10:09:13 -0400 (EDT)
Message-ID: <20161014.100913.2270132305131797982.davem@davemloft.net>
References: <871szk9rl9.fsf@x220.int.ebiederm.org>
	<20161013204405.GA19836@outlook.office365.com>
	<87k2db39zf.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k2db39zf.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Thu, 13 Oct 2016 22:06:28 -0500

> Oh that is a surprise.  We can definitely skip genenerating uevents for
> network namespaces that are exiting because by definition no one can see
> those network namespaces.  If a socket existed that could see those
> uevents it would hold a reference to the network namespace and as such
> the network namespace could not exit.
> 
> That sounds like it is worth investigating a little more deeply.
> 
> I am surprised that allocation and freeing is so heavy we are spending
> lots of time doing that.  On the other hand kobj_bcast_filter is very
> dumb and very late so I expect something can be moved earlier and make
> that code cheaper with the tiniest bit of work.

I definitely would rather see the uevents removed to kill ~%99 of the
namespace removal overhead rather than limiting.
