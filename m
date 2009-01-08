From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 19:56:21 -0500
Message-ID: <20090108005621.GI3164@didacte.laptop.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <20090107210758.GH3164@didacte.laptop.org> <20090107215935.GB4610@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:50012 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753956AbZAHA4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 19:56:22 -0500
Received: from didacte.laptop.org (dhcp-47-72.media.mit.edu [18.85.47.72])
	by mail.laptop.org (Postfix) with SMTP id 0C8D723AD1
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2009 19:56:23 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20090107215935.GB4610@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 12:59:36AM +0300, Evgeniy Polyakov wrote:
>I meant that connected or accepted socket will not be able to send data
>via send() call, but will be able to receive data using recv().

A key fact which may not have stood out, since I didn't comment on it
explicitly in the code, is that the disqualification tests inserted by
the __sock_sendmsg() and unix_dgram_sendmsg hunks contain additional
conditions like

__sock_sendmsg():
+               && (msg->msg_name != NULL || msg->msg_namelen != 0))

unix_dgram_sendmsg():
+                       && !sunaddr->sun_path[0])

which return us to the usual codepaths whenever we're dealing with an
already-connected socket. Since my tests pass, can you post an example
of a failing send() call which you think should work?

>Your patch adds a rlimit check into __sock_sendmsg() call, which is
>invoked via usual send() path, but sendfile() and splice() are still
>exectuted without this check and thus will be able to send data after
>rlimit applied.

As far as I can tell, sendfile() and splice(), which operate solely on
fds, cannot be used to send messages via a disconnected socket.
Therefore, I /believe/ that they require no modification. Am I terribly
mistaken about this?

Thanks,

Michael
