From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] xen-netfront: transmit fully GSO-sized packets
Date: Thu, 26 Mar 2015 17:14:08 +0300
Message-ID: <55141430.9050309@cogentembedded.com>
References: <1427368406-28084-1-git-send-email-jonathan.davies@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>
To: Jonathan Davies <jonathan.davies@citrix.com>,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36733 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbbCZOOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:14:11 -0400
Received: by labe2 with SMTP id e2so46434471lab.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:14:10 -0700 (PDT)
In-Reply-To: <1427368406-28084-1-git-send-email-jonathan.davies@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/26/2015 2:13 PM, Jonathan Davies wrote:

> xen-netfront limits transmitted skbs to be at most 44 segments in size. However,
> GSO permits up to 65536 bytes, which means a maximum of 45 segments of 1448
> bytes each. This slight reduction in the size of packets means a slight loss in
> efficiency.

> Since c/s 9ecd1a75d, xen-netfront sets gso_max_size to

    c/s == commit?
    Please also specify that commit's summary line in parens.

>      XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER,
> where XEN_NETIF_MAX_TX_SIZE is 65535 bytes.

> The calculation used by tcp_tso_autosize (and also tcp_xmit_size_goal since c/s
> 6c09fa09d) in determining when to split an skb into two is

    Likewise.

>      sk->sk_gso_max_size - 1 - MAX_TCP_HEADER.

> So the maximum permitted size of an skb is calculated to be
>      (XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER) - 1 - MAX_TCP_HEADER.

> Intuitively, this looks like the wrong formula -- we don't need two TCP headers.
> Instead, there is no need to deviate from the default gso_max_size of 65536 as
> this already accommodates the size of the header.

> Currently, the largest skb transmitted by netfront is 63712 bytes (44 segments
> of 1448 bytes each), as observed via tcpdump. This patch makes netfront send
> skbs of up to 65160 bytes (45 segments of 1448 bytes each).

> Fixes: 9ecd1a75d977 ("xen-netfront: reduce gso_max_size to account for max TCP header")

    Ah, here's the summary for the first mentioned commit...

> Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>

WBR, Sergei
