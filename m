From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Fri, 03 Sep 2004 04:48:23 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903.044823.82214059.yoshfuji@linux-ipv6.org>
References: <4137681D.3000902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, herbert@debian.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net
In-Reply-To: <4137681D.3000902@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4137681D.3000902@trash.net> (at Thu, 02 Sep 2004 20:36:13 +0200), Patrick McHardy <kaber@trash.net> says:

> Yoshifuji's recent fragment patch prevents unnecessary fragmentation
> when the data can be kept in a single packet, but only for the first
> packet. When fragmenting, all fragments are still truncated to
> multiples of 8 and we might end up creating an unnecessary fragment.
> 
> This dump shows the problem (MTU 1499):
> 
> 172.16.1.123.32771 > 172.16.195.3.4135: udp 2937 (frag 7066:1472@0+)
> 172.16.1.123 > 172.16.195.3: udp (frag 7066:1472@1472+)
> 172.16.1.123 > 172.16.195.3: udp (frag 7066:1@2944)
> 
> This patch always builds mtu sized fragments and truncates the previous
> fragment to a multiple of 8 bytes when allocating a new one. With the
> patch the dump looks like this:
> 
> 
> 172.16.1.123.32772 > 172.16.195.3.4135: udp 2937 (frag 49641:1472@0+)
> 172.16.1.123 > 172.16.195.3: udp (frag 49641:1473@1472)

Let me clarify. 
Are you sending payload of 2945 bytes  (= udp payload of 2937 bytes)?

Good point.

I'll check this patch today. (Let me sleep for now...)
Anyway, please update the comment instead of removing completely.

Thanks.

--yoshfuji
