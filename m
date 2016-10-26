From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git)] net: phy: at803x: disable by default the
 hibernation feature
Date: Wed, 26 Oct 2016 08:08:03 +0200
Message-ID: <33831cdf-7ead-dab1-7948-1dd29bcd07f9@st.com>
References: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
 <20161025090007.GB21818@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50410 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753019AbcJZGIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 02:08:14 -0400
In-Reply-To: <20161025090007.GB21818@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew.

On 10/25/2016 11:00 AM, Andrew Lunn wrote:
>> For example, while booting a Kernel the SYNP MAC (stmmac) fails
>> to initialize own DMA engine if the phy entered in hibernation
>> before.
>
> Have you tried fixing stmmac instead?

Let me describe better what happens, to be honest, this is a
marginal user-case, but, maybe it makes sense to share this patch in
case of somebody meets the same issue.

When performing "ifconfig eth0 up", if this phy is not in hibernation,
the iface comes up w/o any issues.
If the PHY is in hibernation, because the cable is unplugged (and
this is a default for these transceivers), the phy clock does down and
the MAC cannot init own DMA. The stmmac is designed to fail the open in
this case.
If I plug the cable the next ifconfig up is ok.

The meaning of the patch, I proposed, is to remove by default this
hibernation feature at PHY level that, for me, should be an option
not a default. For example, I have used other HW where some
power state features could be enabled but, by default, were turned
off. Also these transceivers support EEE so, I guess, there is all the
technology to manage the power consumption on new setup.

Concerning the stmmac, how the driver could fix this situation?
The PHY does not provide the clock required for GMAC and the stmmac
cannot reset own DMA. I had thought to delay this as soon as the link
is UP but I don't like this approach where the open should return
a sane state but this is not true and we should wait the ACK from the
PHY to reset the MAC DMAC.

Anyway, as said, the patch covers a marginal user-case so feel free to
consider it or not. For sure, I am open to change something at MAC
level if you have better idea.

Regards
Peppe

>
>      Andrew
>
