From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Should use consistent conditional judgement
 for ip fragment in __ip_append_data and ip_finish_output
Date: Tue, 20 Dec 2016 10:45:46 -0500 (EST)
Message-ID: <20161220.104546.1863252338196704503.davem@davemloft.net>
References: <1481507765-3684-1-git-send-email-lizheng043@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, james.z.li@ericsson.com
To: lizheng043@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481507765-3684-1-git-send-email-lizheng043@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <lizheng043@gmail.com>
Date: Mon, 12 Dec 2016 09:56:05 +0800

> From: zheng li <james.z.li@ericsson.com>
> 
> There is an inconsistent conditional judgement in __ip_append_data and
> ip_finish_output functions, the variable length in __ip_append_data just
> include the length of application's payload and udp header, don't include
> the length of ip header, but in ip_finish_output use
> (skb->len > ip_skb_dst_mtu(skb)) as judgement, and skb->len include the
> length of ip header.
> 
> That causes some particular application's udp payload whose length is
> between (MTU - IP Header) and MTU were fragmented by ip_fragment even
> though the rst->dev support UFO feature.
> 
> Add the length of ip header to length in __ip_append_data to keep
> consistent conditional judgement as ip_finish_output for ip fragment.
> 
> Signed-off-by: Zheng Li <james.z.li@ericsson.com>

Applied, thanks.
