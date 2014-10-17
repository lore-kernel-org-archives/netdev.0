From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Fri, 17 Oct 2014 12:48:05 -0700
Message-ID: <1413575285.27176.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
	 <1413409168.17186.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1413409354.17186.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141017.152923.678515861731659347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, kkolasa@winsoft.pl, edumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37796 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbaJQTsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 15:48:07 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so1322694pdi.19
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 12:48:06 -0700 (PDT)
In-Reply-To: <20141017.152923.678515861731659347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 15:29 -0400, David Miller wrote:
> So I applied Cong's patches, but if I am to understand the testing feedback
> so far only the 64-bit case of the reporter's problems is fixed, and that
> the 32-bit graphics corruption still happens.
> 
> Can I get some clarification of where we stand after Cong's fixes
> which are already merged into 'net'?

I spent some time on the (awful) memmove() implementation on x86_32, and
could not find a bug in it.

It would be worth trying doing 2 memcpy() instead just in case...
