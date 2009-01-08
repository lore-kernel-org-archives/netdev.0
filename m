From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Thu, 8 Jan 2009 07:27:15 +0300
Message-ID: <20090108042715.GA16187@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <20090107210758.GH3164@didacte.laptop.org> <20090107215935.GB4610@ioremap.net> <20090108005621.GI3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:52697 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbZAHE1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 23:27:18 -0500
Content-Disposition: inline
In-Reply-To: <20090108005621.GI3164@didacte.laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 07:56:21PM -0500, Michael Stone (michael@laptop.org) wrote:
> On Thu, Jan 08, 2009 at 12:59:36AM +0300, Evgeniy Polyakov wrote:
> >I meant that connected or accepted socket will not be able to send data
> >via send() call, but will be able to receive data using recv().
> 
> A key fact which may not have stood out, since I didn't comment on it
> explicitly in the code, is that the disqualification tests inserted by
> the __sock_sendmsg() and unix_dgram_sendmsg hunks contain additional
> conditions like
> 
> __sock_sendmsg():
> +               && (msg->msg_name != NULL || msg->msg_namelen != 0))
> 
> unix_dgram_sendmsg():
> +                       && !sunaddr->sun_path[0])
> 
> which return us to the usual codepaths whenever we're dealing with an
> already-connected socket. Since my tests pass, can you post an example
> of a failing send() call which you think should work?

You are right, I misread the documentation part where it is explained
that already connected sockets are allowed to operate. Btw that code
part breaks codying style with trailing '\' and '&&' on the new line.
There should be something wrong in the patch :)

> >Your patch adds a rlimit check into __sock_sendmsg() call, which is
> >invoked via usual send() path, but sendfile() and splice() are still
> >exectuted without this check and thus will be able to send data after
> >rlimit applied.
> 
> As far as I can tell, sendfile() and splice(), which operate solely on
> fds, cannot be used to send messages via a disconnected socket.
> Therefore, I /believe/ that they require no modification. Am I terribly
> mistaken about this?

No you are not, as long as user is allowed to operate with already
connected and/or bound sockets there should be no problems.

-- 
	Evgeniy Polyakov
