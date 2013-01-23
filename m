From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Wed, 23 Jan 2013 11:28:08 -0800
Message-ID: <510039C8.7040401@hp.com>
References: <20130122161038.GG4608@sociomantic.com> <1358873142.3464.3964.camel@edumazet-glaptop> <20130122165929.GH4608@sociomantic.com> <1358874800.3464.4002.camel@edumazet-glaptop> <50FED7CE.1030008@hp.com> <20130122184245.GJ4608@sociomantic.com> <50FF0C25.9000300@hp.com> <20130123104736.GK4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:28800 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab3AWT2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 14:28:10 -0500
In-Reply-To: <20130123104736.GK4608@sociomantic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 02:47 AM, Leandro Lucarella wrote:
> Thanks for the info. I'm definitely dropping SYNs and sending cookies,
> around 50/s. Is there any way to tell how many connections are queued in
> a particular socket?

I am not familiar with one.  Doesn't mean there isn't one, only that I 
am not able to think of it.

> Then if syncookies are enabled, the time spent in connect() shouldn't be
> bigger than 3 seconds even if SYNs are being "dropped" by listen, right?

Do you mean if "ESTABLISHED" connections are dropped because the listen 
queue is full?  I don't think I would put that as "SYNs being dropped by 
listen" - too easy to confuse that with an actual dropping of a SYN segment.

But yes, I would not expect a connect() call to remain incomplete for 
any longer than it took to receive an SYN|ACK from the other end.  That 
would be 3 (,9, 21, etc...) seconds on a kernel with 3 seconds as the 
initial retransmission timeout.

rick
