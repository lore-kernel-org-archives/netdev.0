From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: query: tcpdump versus atomic?
Date: Wed, 14 Oct 2009 08:59:41 -0700
Message-ID: <20091014085941.6897d9d9@nehalam>
References: <4AD5522B.50101@gmail.com>
	<4AD5EC2C.6070005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51560 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761945AbZJNQAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 12:00:23 -0400
In-Reply-To: <4AD5EC2C.6070005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Oct 2009 11:20:12 -0400
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> William Allen Simpson wrote:
> > Anybody know what code path tcpdump changes to running atomic?
> > 
> > Is there a function to test whether you're running atomic?
> > 
> To partially answer my own question, after laboriously #if'ing compiling
> section by section, it affects the tcp_minisockets.c code at
> tcp_create_openreq_child().
> 
> I've not found a function to test.  I've found sk->sk_allocation, but
> that doesn't seem to be dynamically updated to reflect the current state.
> 
> Anyway, sorry David, but there's at least two GFP_ATOMIC here (one existing,
> one new).  I've managed to change the others, by careful rearrangement.  At
> least, I hope so, until some future testing reveals otherwise....
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

did you look at your ethernet's drivers code to turn on promiscuous mode.
It could be leaving irq's or bottom half disabled.

-- 
