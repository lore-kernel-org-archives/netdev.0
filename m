From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] Add c/r support for connected INET sockets
 (v4)
Date: Wed, 11 Nov 2009 14:32:44 -0600
Message-ID: <20091111203244.GC8761@us.ibm.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
 <1257878856-25520-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:39989 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757270AbZKKUcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:32:55 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nABKUk9I008560
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 13:30:46 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nABKWjNm121050
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 13:32:50 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nABESMRs007035
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 07:28:22 -0700
Content-Disposition: inline
In-Reply-To: <1257878856-25520-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.
> 
> We probably need comments from the netdev people about the quality of
> sanity checking we do on the values in the ckpt_hdr_socket_inet
> structure on restart.
> 
> Note that this still doesn't address lingering sockets yet.
> 
> Changes in v4:
>  - Use the new socket buffer restore functions introduced in the
>    previous patch
>  - Move listen_sockets list under the restart items in ckpt_ctx
>  - Rename RESTART_SOCK_LISTENONLY to RESTART_CONN_RESET
> 
> Changes in v3:
>  - Prevent restart from allowing a bind on a <1024 port unless the
>    user is granted that capability
>  - Add some sanity checking in the inet_precheck() function to make sure
>    the values read from the checkpoint image are within acceptable ranges
>  - Check the result of sock_restore_header_info() and fail if needed
> 
> Changes in v2:
>  - Restore saddr, rcv_saddr, daddr, sport, and dport from the sockaddr
>    structure instead of saving them separately
>  - Fix 'sock' naming in sock_cptrst()
>  - Don't take the queue lock before skb_queue_tail() since it is
>    done for us
>  - Allow "listen only" restore behavior if RESTART_SOCK_LISTENONLY
>    flag is specified on sys_restart()
>  - Pull the implementation of the list of listening sockets back into
>    this patch
>  - Fix dangling printk
>  - Add some comments around the parent/child restore logic
> 
> Cc: netdev@vger.kernel.org
> Acked-by: Oren Laadan <orenl@librato.com>
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: Serge Hallyn <serue@us.ibm.com>

There are probably still gremlins in there somewhere, but imo it's
past time to get this in the tree so we can be testing it.

-serge
