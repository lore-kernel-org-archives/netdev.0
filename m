From: Phil Sutter <phil@nwl.cc>
Subject: Re: af_packet: when sending ethernet frames, parse header for
 skb->protocol
Date: Thu, 8 Aug 2013 23:19:38 +0200
Message-ID: <20130808211943.EA1E8226BB@mail.nwl.cc>
References: <20130807220303.GA3478@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47867 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966555Ab3HHVUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 17:20:11 -0400
Content-Disposition: inline
In-Reply-To: <20130807220303.GA3478@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Aug 08, 2013 at 02:03:03AM +0400, Andrew Vagin wrote:
> I compiled the akpm branch of linux-next and found that my virtual
> machine didn't get an IP address by dhcp.
> 
> git bisect said that the problem is in "af_packet: when sending ethernet
> frames, parse header for skb->protocol"
> 
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=0f75b09c798ed00c30d7d5551b896be883bc2aeb
> 
> I have double checked, the VM gets an IP address w/o this patch and it
> does not get an address with this patch.
> 
> Let me know if you need any information to investigate this issue.

Thanks for your investigation. I could reproduce your problem, the
culprit was the skb->data pointer changed as a side effect in
eth_type_trans().

Best wishes, Phil
