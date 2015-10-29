From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use l4 hash for locally generated
 multipath flows
Date: Thu, 29 Oct 2015 07:31:10 -0700
Message-ID: <1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, pch@ordbogen.com
To: Paolo Abeni <pabeni@redhat.com>,
	Peter =?ISO-8859-1?Q?N=F8rlund?= <pch@ordbogen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33600 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbJ2ObO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 10:31:14 -0400
Received: by padhy1 with SMTP id hy1so36709125pad.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 07:31:14 -0700 (PDT)
In-Reply-To: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-28 at 18:39 +0100, Paolo Abeni wrote:
> This patch changes how the multipath hash is computed for locally
> generated UDP or TCP flows: now the hash comprises also l4 information
> (source and destination port).
> 
> This allows better utilization of the available paths when the existing
> flows have the same source IP and the same destination IP: with l3 hash,
> even when multiple connections are in place simultaneously, a single path
> will be used, while with l4 hash we can use all the available paths.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Please note that many skb already have a l4 hash. No need to perform yet
another dissection.

This would work even for tunneled traffic...

See commit 4b1b865e4e97e336316f30e32af36d71e98bdabc for an example.
