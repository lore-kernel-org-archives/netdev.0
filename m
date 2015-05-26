From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Tue, 26 May 2015 15:51:42 -0700
Message-ID: <20150526225142.GB26454@roeck-us.net>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?iso-8859-1?Q?J=E9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35870 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbEZWvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 18:51:47 -0400
Content-Disposition: inline
In-Reply-To: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 06:29:57PM -0400, Vivien Didelot wrote:
> Hi,
> 
> I'm doing tests with VLAN support in DSA and I noticed that the EDSA 
> frame is prepended with a 802.1q header once queued to the underlying 
> network device, in net/dsa/tag_edsa.c:
> 
>     skb->dev = p->parent->dst->master_netdev;
>     dev_queue_xmit(skb);
> 
> This issue can be observed with the following dump:
> 
>     curl -s http://ix.io/iIv | tcpdump -en -r -
> 
> I suspect that the DSA code must clear some VLAN flags in the skb
> structure, in order to prevent the additional encapsulation by the lower
> level. Does this make sense?
> 

Hi Vivien,

Interesting question. Does the underlying network device support VLAN HW
acceleration (NETIF_F_HW_VLAN_CTAG_RX, NETIF_F_HW_VLAN_CTAG_TX) ?

If yes, the dsa code may need to move the tag into the header.
If we are lucky, a call to vlan_hwaccel_push_inside() might do it.

Do you have some vlan dsa code to share, by any chance ? That might
save me some time, as I am looking into it as well.

Thanks,
Guenter
