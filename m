From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: tcpdump versus atomic?
Date: Wed, 14 Oct 2009 11:20:12 -0400
Message-ID: <4AD5EC2C.6070005@gmail.com>
References: <4AD5522B.50101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:37768 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756686AbZJNPUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 11:20:53 -0400
Received: by fxm27 with SMTP id 27so11718573fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 08:20:16 -0700 (PDT)
In-Reply-To: <4AD5522B.50101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> Anybody know what code path tcpdump changes to running atomic?
> 
> Is there a function to test whether you're running atomic?
> 
To partially answer my own question, after laboriously #if'ing compiling
section by section, it affects the tcp_minisockets.c code at
tcp_create_openreq_child().

I've not found a function to test.  I've found sk->sk_allocation, but
that doesn't seem to be dynamically updated to reflect the current state.

Anyway, sorry David, but there's at least two GFP_ATOMIC here (one existing,
one new).  I've managed to change the others, by careful rearrangement.  At
least, I hope so, until some future testing reveals otherwise....

