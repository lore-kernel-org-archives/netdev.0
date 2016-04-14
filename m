From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH nf] netfilter: ipv6: Orphan skbs in nf_ct_frag6_gather()
Date: Thu, 14 Apr 2016 08:31:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4A226C@AcuExch.aculab.com>
References: <1460570974-44050-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "fw@strlen.de" <fw@strlen.de>,
	"diproiettod@vmware.com" <diproiettod@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Joe Stringer' <joe@ovn.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:61115 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbcDNId2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 04:33:28 -0400
In-Reply-To: <1460570974-44050-1-git-send-email-joe@ovn.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer
> Sent: 13 April 2016 19:10
> This is the IPv6 equivalent of commit 8282f27449bf ("inet: frag: Always
> orphan skbs inside ip_defrag()").
> 
> Prior to commit 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free
> clone operations"), ipv6 fragments sent to nf_ct_frag6_gather() would be
> cloned (implicitly orphaning) prior to queueing for reassembly. As such,
> when the IPv6 message is eventually reassembled, the skb->sk for all
> fragments would be NULL. After that commit was introduced, rather than
> cloning, the original skbs were queued directly without orphaning. The
> end result is that all frags except for the first and last may have a
> socket attached.

I'd have thought that the queued fragments would still want to be
resource-counted against the socket (I think that is what skb->sk is for).
So don't really want to orphan skb before queuing them, instead transfer
the entire resource count to the head skb when they are merged.

Although I can't imagine why IPv6 reassembly is happening on skb
associated with a socket.

	David
