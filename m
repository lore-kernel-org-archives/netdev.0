From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Wed, 11 Feb 2004 16:01:52 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.160152.48476158.yoshfuji@linux-ipv6.org>
References: <20040211.120234.92333563.yoshfuji@linux-ipv6.org>
	<OFA69E1A86.43DC582D-ON88256E37.0016A3A7-88256E37.00195210@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFA69E1A86.43DC582D-ON88256E37.0016A3A7-88256E37.00195210@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFA69E1A86.43DC582D-ON88256E37.0016A3A7-88256E37.00195210@us.ibm.com> (at Tue, 10 Feb 2004 21:39:15 -0700), David Stevens <dlstevens@us.ibm.com> says:

> "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp> wrote on
> 02/10/2004 07:02:34 PM:
> 
> > My point is, !(skb->dev->flags & IFF_PROMISC|IFF_ALLMULTI) is likely
> true.
> 
> Yes, "deliver" is set to the expression that includes the check
> "!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))" and it is likely
> true, which is why the patch I sent has "if (likely(deliver)) {"
> in it.
> 
> I don't understand what you're suggesting. If you aren't suggesting
> that I remove the "deliver" variable (which is needed again when you
> enable the "#if 0" part), then I think your suggestion is already
> in the patch. Can you explain?

David, they produce different assembly code.

If we say
        deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
                  ipv6_chk_mcast_addr(skb->dev, &skb->nh.ipv6h->daddr, NULL);
then we can run the next code without breaking pipeline in the CPU
if !(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) is true.
This condition is true with good device and driver.

If you say
        deliver = !(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
                  ipv6_chk_mcast_addr(skb->dev, &skb->nh.ipv6h->daddr, NULL);
then you brean the pipeline.

objdump -d will help you. :-)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
