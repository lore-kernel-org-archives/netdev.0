From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Tue, 13 Oct 2009 12:12:59 -0700
Message-ID: <87pr8rcdl0.fsf@caffeine.danplanet.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-3-git-send-email-danms@us.ibm.com>
	<4AD3A52B.6050101@librato.com> <87ws2zcjhe.fsf@caffeine.danplanet.com>
	<4AD4CE61.30503@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        John Dykstra <jdykstra72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AD4CE61.30503-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Tue\,
	13 Oct 2009 15\:00\:49 -0400")
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

OL> IIRC, the TCP stack takes the timestamp for each packet directly
OL> from jiffies. So you need to teach TCP to add a per-container (or
OL> you can make it per-socket) delta to that timestamp.

After wondering what the heck you were talking about, I realized I
assumed you were talking about TCP timeouts and not timestamps :)

I assume you mean the following:

  1. Put a absolute time stamp in the checkpoint stream
  2. Calculate the delta between that and the current time on the
     restoring host
  3. Use that value to offset timestamps from that point on.

Correct?

Since I brought it up, do you agree that the retransmit timers should
be canonicalized to time-after checkpoint values?  It occurs to me
that right now I restore a jiffies value on the receiving host which
is guaranteed to be incorrect :)

OL> So I'm thinking, for both, do (1) put a big fat comment in the
OL> code saying that sanity-tests are needed, and what for, and (2)
OL> send a separate mail to the networking people with these two
OL> scenarios and request comments ?

Yeah, although I would hope that they're seeing this conversation and
would chime in (hence the cc:netdev).  Hopefully I don't have to
disguise a separate email as non-C/R related to get past their
filters! :)

OL> For example, now, if a user wants to send a TCP packet with
OL> arbitrary protocol parameters, he needs to use raw IP sockets,
OL> which require privilege. Would restarting a connection with the
OL> desired parameters become a way to bypass that restriction ?
OL> (e.g. assume the user restarts while using the host's network
OL> namespace).

Um, yeah?  I don't see much way around that if we're going to trust
any of what is in the checkpoint stream.  Perhaps we say CAP_NET_ADMIN
is required to restart a live TCP connection?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
