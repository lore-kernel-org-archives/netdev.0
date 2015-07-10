From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer for
 kernel users
Date: Fri, 10 Jul 2015 06:25:28 -0400
Message-ID: <20150710102527.GA21910@hmsreliant.think-freely.org>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47022 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbGJKZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 06:25:37 -0400
Content-Disposition: inline
In-Reply-To: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2015 at 11:15:19AM -0300, Marcelo Ricardo Leitner wrote:
> SCTP has this operation to peel off associations from a given socket and
> create a new socket using this association. We currently have two ways
> to use this operation:
> - via getsockopt(), on which it will also create and return a file
>   descriptor for this new socket
> - via sctp_do_peeloff(), which is for kernel only
> 
> The caveat with using sctp_do_peeloff() directly is that it creates a
> dependency to SCTP module, while all other operations are handled via
> kernel_{socket,sendmsg,getsockopt...}() interface. This causes the
> kernel to load SCTP module even when it's not directly used
> 
> This patch then updates SCTP_SOCKOPT_PEELOFF so that for kernel users of
> this protocol it will not allocate a file descriptor but instead just
> return the socket pointer directly.
> 
> If called by an user application it will work as before.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Neil Horman <nhorman@tuxdriver.com>
