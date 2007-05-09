From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix hang on IBM Token Ring PCMCIA card ejection
Date: Wed, 09 May 2007 19:25:33 -0400
Message-ID: <4642586D.4070300@garzik.org>
References: <20070509164715.430844867@booyaka.com> <20070509164803.557732761@booyaka.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net
To: Paul Walmsley <paul@booyaka.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50085 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759177AbXEIXZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:25:36 -0400
In-Reply-To: <20070509164803.557732761@booyaka.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Walmsley wrote:
> Ejecting a PCMCIA IBM Token Ring card that has not had its dev->open()
> called will reliably trigger an uninitialized spinlock oops when
> spinlock debugging is enabled. The system then hangs, occasionally
> softlockup oopsing.  Apparently ibmtr.c:tok_interrupt() doesn't expect
> to be called before tok_open(), but tok_interrupt() gets called anyway
> when the card is ejected.  So, set an already-existing flag which
> causes tok_interrupt() to bail out early upon card ejection. Tested by
> inserting and removing the PCMCIA card several times.
> 
> Patch against 2.6.21-rc6.
> 
> 
> Signed-off-by: Paul Walmsley <paul@booyaka.com>
> 
> ---
>  ibmtr_cs.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)

applied


