From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sb1000.c: stop inlining largish static functions
Date: Sat, 12 Apr 2008 05:08:16 -0400
Message-ID: <48007C00.7070100@garzik.org>
References: <200803310102.43277.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38831 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758880AbYDLJIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:08:18 -0400
In-Reply-To: <200803310102.43277.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Vlasenko wrote:
> Hi Jeff,
> 
> Can you take this patch into your net driver fixes tree?
> 
> drivers/net/sb1000.c has lots of inlined static functions.
> 
> Mst of them are used at initialization, wait for some
> hardware register to change (wait using yield, sleep etc),
> or do slow port-based I/O. Inlining thse "for speed" makes no sense.
> 
> This patch removes "inline" from biggest static function
> (regardless of number of callsites - gcc nowadays auto-inlines
> statics with one callsite).
> 
> Size difference for 32bit x86:
> 
>    text    data     bss     dec     hex filename
>    6299     129       0    6428    191c linux-2.6-ALLYES/drivers/net/sb1000.o
>    5418     129       0    5547    15ab linux-2.6.inline-ALLYES/drivers/net/sb1000.o
> 
> (I also see some other optimization opportunities,
> will test and send a patch separately).
> 
> Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>

applied both patches


