From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission for S2io 10GbE driver
Date: Thu, 19 Feb 2004 03:14:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40347076.8030105@pobox.com>
References: <4223A04BF7D1B941A25246ADD0462FF5010FA5EB@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: leonid.grossman@s2io.com, netdev@oss.sgi.com, raghavendra.koushik@s2io.com,
        ravinandan.arakali@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@wipro.com
In-Reply-To: <4223A04BF7D1B941A25246ADD0462FF5010FA5EB@blr-m3-msg.wipro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

raghavendra.koushik@wipro.com wrote:
> Hi Jeff,
> 
> 1. points 7 and 8, when initSharedMem returns error, I call
> freeSharedMem which should free any partially alloced memory.

For #8 quite possibly, and if so, I stand corrected.

For #7, it's a temporary variable so this would be impossible.


> 2. For point 17 and 33
> We do support IPV6 checksum offload. There is one issue though,
> our hardware only says whether the checksum is Ok or not it does
> not actually return the checksum values!
[...]
> If I say features as NETIF_F_IP_CSUM instead of NETIF_F_HW_CSUM,
> then I cannot utilize it's entire gamut of checksum offload feature
> as the offload will be limited to just TCP/UDP over IPV4.

Correct.  Your hardware cannot utilize NETIF_F_HW_CSUM.  You must be 
able to supply a valid csum from hardware, to use NETIF_F_HW_CSUM. 
Using NETIF_F_HW_CSUM as s2io does is abuse of the API, and prone to 
breakage...

For the future, it sounds like you should create a NETIF_F_IPV6_CSUM 
that works for both IPv4 and IPv6, and more closely matches your 
hardware.  We need to do this anyway, because most future cards will 
almost certainly offload IPv6 as well as IPv4.

For the present, NETIF_F_IP_CSUM is unfortunately your only choice. 
Zero-copy only occurs for sendfile(2) system call, which works fine with 
NETIF_F_IP_CSUM, so no big deal.

In general, I certainly want to encourage s2io to participate in adding 
features to Linux that is needed to more fully utilize the hardware. 
Some of the proposed features might not be appropriate, but adding 
NETIF_F_IPV6_CSUM for you guys certainly seems reasonable.

	Jeff
