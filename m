From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Wed, 12 Aug 2009 11:29:36 -0400
Message-ID: <4A82DFE0.4040108@librato.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com> <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp221.iad.emailsrvr.com ([207.97.245.221]:43530 "EHLO
	smtp221.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbZHLPaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 11:30:00 -0400
In-Reply-To: <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan,

I just noticed that this message wasn't posted last night.
So hitting "send" now ... sorry about that.

-----
Before pulling this one, I took a quick look at this patch, and
I saw that it still uses skb_morph despite the changelog and my
memory...

Can you please verify that this is the latest ?

Also, while trying to pull it, I'd like to ask for three cosmetic
changes, if it isn't too much -

1) Move 'struct ckpt_hdr_socket' et-al to checkpoint_hdr.h

2) Move everything that is af_unix specific from net/checkpoint.c
to (a new) net/unix/checkpoint.c (prototypes probably in af_unix.h ?)

3) Make sure that af_unix code does not compile (and is not called
from net/checkpoint.c) unless CONFIG_UNIX is defined.

I pulled all the other patches already, will add this one once
you resend.
-----

Thanks,

Oren.


Dan Smith wrote:
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports socketpair()s, path-based, and
> abstract sockets.
> 
> Changes in v8:
>   - Fix stale dev_alloc_skb() from before the conversion to skb_clone()
>   - Fix a couple of broken error paths
>   - Fix memory leak of kvec.iov_base on successful return from sendmsg()
>   - Fix condition for deciding when to run sock_cptrst_verify()
>   - Fix buffer queue copy algorithm to hold the lock during walk(s)
>   - Log the errno when either getname() or getpeer() fails
>   - Add comments about ancillary messages in the UNIX queue
>   - Add TODO comments for credential restore and flags via setsockopt()
>   - Add TODO comment about strangely-connected dgram sockets and the use
>     of sendmsg(peer)
> 
> Changes in v7:
>   - Fix failure to free iov_base in error path of sock_read_buffer()
>   - Change sock_read_buffer() to use _ckpt_read_obj_type() to get the
>     header length and then use ckpt_kread() directly to read the payload
>   - Change sock_read_buffers() to sock_unix_read_buffers() and break out
>     some common functionality to better accommodate the subsequent INET
>     patch
>   - Generalize sock_unix_getnames() into sock_getnames() so INET can use it
>   - Change skb_morph() to skb_clone() which uses the more common path and
>     still avoids the copy
>   - Add check to validate the socket type before creating socket
>     on restore
>   - Comment the CAP_NET_ADMIN override in sock_read_buffer_hdr
>   - Strengthen the comment about priming the buffer limits
>   - Change the objhash functions to deny direct checkpoint of sockets and
>     remove the reference counting function
>   - Change SOCKET_BUFFERS to SOCKET_QUEUE
>   - Change this,peer objrefs to signed integers
>   - Remove names from internal socket structures
>   - Fix handling of sock_copy_buffers() result
>   - Use ckpt_fill_fname() instead of d_path() for writing CWD
>   - Use sock_getname() and sock_getpeer() for proper security hookage
>   - Return -ENOSYS for unsupported socket families in checkpoint and restart
>   - Use sock_setsockopt() and sock_getsockopt() where possible to save and
>     restore socket option values
>   - Check for SOCK_DESTROY flag in the global verify function because none
>     of our supported socket types use it
>   - Check for SOCK_USE_WRITE_QUEUE in AF_UNIX restore function because
>     that flag should not be used on such a socket
>   - Check socket state in UNIX restart path to validate the subset of valid
>     values

[...]


