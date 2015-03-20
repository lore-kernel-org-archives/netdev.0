From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Get statistics from all network interfaces on a system,
	including those inside network namespaces
Date: Fri, 20 Mar 2015 15:10:15 -0500
Message-ID: <87bnjnctw8.fsf@x220.int.ebiederm.org>
References: <CAFZrTr52ksuMaJKbNGmQ3NuNLjRe8T15gaDvxuJ66errGN7g3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeremias Blendin <jeremias-ZqkW+k4+4H9AfugRpC6u6w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFZrTr52ksuMaJKbNGmQ3NuNLjRe8T15gaDvxuJ66errGN7g3g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Jeremias Blendin's message of "Thu, 19 Mar 2015 14:22:21 +0100")
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

Jeremias Blendin <jeremias-ZqkW+k4+4H9AfugRpC6u6w@public.gmane.org> writes:

> Hi,
>
> I hope this is the right list to post this question.

This list and netdev are the right lists.  It is one of those
overlapping topics.

Right now I find applications dealing with multiple network namespaces
interesting as the APIs are a little rough and it is time to knock off
some of the rough edges.

> Currently, we are using a patched version of bwm-ng to poll statistics
> of network interfaces. Some of these interfaces are located inside
> network namespaces, unfortunately we have found no way to poll all
> interfaces from all netspaces at once, without making our client
> application process traverse through all the available network
> namespaces (one result is this patch for bwm-ng:
> https://github.com/jgjl/bwm-ng/tree/lxns).
> Is there a more efficient way (for example by using netlink directly)
> to get a complete list of the statistics of all network interfaces
> existing in the kernel e.g. tagged by their netns?

Not at this point.  Although we have ids that are now possible of that
tagging.  At this point you need to have a separate socket for each
network namespace.

All network devices in all network namespaces is not going to ever
happen as that makes nested containers and migration impossible.  All
network devices in an interesting subset of network namespaces is a very
reasonable request.

> Any pointers are appreciated :)

I would look at iproute2.  Looking at the description of your code you
don't even pick up on the names that have been assigned to network
namespaces.  So I don't think you are up to speed on everything that is
going on there.

Eric
