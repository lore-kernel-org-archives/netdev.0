From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 09:55:46 -0700
Message-ID: <8763e3qfl9.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-2-git-send-email-danms@us.ibm.com>
	<4A543D82.5080408@cs.columbia.edu>
	<87ljmzqjvl.fsf@caffeine.danplanet.com>
	<4A54CCDB.1090602@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A54CCDB.1090602-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 08 Jul 2009 12\:44\:11 -0400")
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

OL> It will mostly fix the buffer limits, but not entirely: if the
OL> original socket first raised the limits above defualt, then sent
OL> data (not read by peer), then you'll still need to adjust the
OL> limit before restoring the buffers.

If we cap the buffers in the checkpoint image to the current system
limit (sysctl) and then set the per-socket buffer limit (after reading
them in) to the value in the checkpoint image then we get the desired
result, right?

OL> I can't predict the future, but it's been there forever...

Yeah, after I sent that I remembered that the magic 108 is in the
sockaddr_un structure which is a userspace API and therefore not
likely to change.

OL> But the point is that I would interpret ENOSPC as "storage/space
OL> is exhausted", while here the error is that this value is simply
OL> invalid for the particular kernel on which the restart occurs.

Yep, fair enough.

OL> In the original system, once the file becomes unreachable it
OL> cannot be made reachable again by simple (re)mounting, IOW it can
OL> no longer be connected-to.

Ah, I thought you meant "was reachable on the source system and not
reachable on the target system".  I'm with you now :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
