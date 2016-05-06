From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/2] udp_offload: Set encapsulation before inner
 completes.
Date: Fri, 06 May 2016 18:25:48 -0400 (EDT)
Message-ID: <20160506.182548.2125009837273287619.davem@davemloft.net>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
	<1462317021-7236-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse@kernel.org
To: jarno@ovn.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462317021-7236-2-git-send-email-jarno@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jarno@ovn.org>
Date: Tue,  3 May 2016 16:10:21 -0700

> UDP tunnel segmentation code relies on the inner offsets being set for
> an UDP tunnel GSO packet, but the inner *_complete() functions will
> set the inner offsets only if 'encapsulation' is set before calling
> them.  Currently, udp_gro_complete() sets 'encapsulation' only after
> the inner *_complete() functions are done.  This causes the inner
> offsets having invalid values after udp_gro_complete() returns, which
> in turn will make it impossible to properly segment the packet in case
> it needs to be forwarded, which would be visible to the user either as
> invalid packets being sent or as packet loss.
> 
> This patch fixes this by setting skb's 'encapsulation' in
> udp_gro_complete() before calling into the inner complete functions,
> and by making each possible UDP tunnel gro_complete() callback set the
> inner_mac_header to the beginning of the tunnel payload.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> v3: Added setting inner_mac_header from all possible callbacks to cover
>     cases where there is no inner mac header.

Applied.
