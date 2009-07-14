From: Yinglin Sun <yinglinsun@cs.pitt.edu>
Subject: Re: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
	retransmissions
Date: Tue, 14 Jul 2009 15:49:52 -0400
Message-ID: <46bf9ede0907141249x7823c199uf3867b4d8284eb1c@mail.gmail.com>
References: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
	 <20090714.114211.254914419.davem@davemloft.net>
	 <46bf9ede0907141212x7a7a84f8l1882ffefbaf21e14@mail.gmail.com>
	 <20090714.121528.15246520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:51909 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbZGNTty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:49:54 -0400
Received: by ey-out-2122.google.com with SMTP id 9so685852eyd.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 12:49:52 -0700 (PDT)
In-Reply-To: <20090714.121528.15246520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2009 at 3:15 PM, David Miller<davem@davemloft.net> wrote:
> From: Yinglin Sun <yinglinsun@cs.pitt.edu>
> Date: Tue, 14 Jul 2009 15:12:16 -0400
>
>> I use the total number of retransmissions reported by tcp_info. The
>> field name is tcpi_total_retrans. From the kernel source code, I found
>> that this number is for both fast retransmit and timeout
>> retransmissions. On the other hand, if fast retransmission happened,
>> ca_state should be TCP_CA_Recovery or TCP_CA_Disorder, but it's
>> TCP_CA_CWR.
>
> Great, that if you're reading the code you also see that there
> are many code paths that invoke tcp_enter_cwr() that can occur
> without any retransmissions. :-)
>
> One such case is when ECN congestion notification bits are
> seen in an ACK packet.
>

Hi David,

Thanks for your reminding. I have checked all paths to
tcp_enter_cwr(). Two of them are FRTO and ECN. Both frto and ECN on my
sender and receiver are NOT enabled, so these two are not causes.
Another one is tcp_transmit_skb(). It seems that tcp_transmit_skb
detects if TX Queue is full. If so, it calls tcp_enter_cwr. I double
checked these invocation paths. If  I found all paths, the cause for
me is that TX Q is full, that is, local congestion. But it is also
possible that I missed other possible causes. Do you have any idea
about other invocation to tecp_enter_cwr?

Thanks a lot.

Yinglin
