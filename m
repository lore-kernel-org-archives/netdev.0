From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Thu, 08 Oct 2009 10:34:11 -0700
Message-ID: <8763apg57w.fsf@caffeine.danplanet.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-3-git-send-email-danms@us.ibm.com>
	<1255013233.8033.14.camel@Maple>
	<87ab01gag7.fsf@caffeine.danplanet.com>
	<1255023087.8033.17.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1255023087.8033.17.camel@Maple> (John Dykstra's message of "Thu\,
	08 Oct 2009 12\:31\:27 -0500")
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

JD> Yep.  It sort of messes up your separation between layers, though.

In what way?  It's just this:

diff --git a/net/checkpoint.c b/net/checkpoint.c
index 3d6da68..f74ebe4 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -687,7 +687,8 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
        /* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
        h->sock.type &= SOCK_TYPE_MASK;
 
-       ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
+       ret = sock_create(h->sock_common.family, h->sock.type,
+                         h->sock.protocol, &sock);
        if (ret < 0)
                goto err;

Which seems like a why-didn't-I-do-that-in-the-first-place sort of
thing...   Am I missing something?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
