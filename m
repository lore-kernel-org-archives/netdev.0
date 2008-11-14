From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: macb phy address bug?
Date: Fri, 14 Nov 2008 09:46:53 +0100
Message-ID: <491D3AFD.1080509@st.com>
References: <200811140853.13729.giulio.benetti@micronovasrl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giulio Benetti <giulio.benetti@micronovasrl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:38919 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbYKNIty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 03:49:54 -0500
In-Reply-To: <200811140853.13729.giulio.benetti@micronovasrl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giulio Benetti wrote:
> PHYID returns 0xffff and not 0xffffffff when not found and in some 
> case(at91sam9263) 0x0. Maybe this patch could be useful.
>
>
>
> Signed-off-by: Giulio Benetti <giulio.benetti@micronovasrl.com>
>   
Hi Giulio,
it sounds like a work around for a hardware error.
Is my understanding that, broken hardware is sometimes missing the pull 
down resistor on the  MDIO line, which results in reads to non-existent 
devices returning  0 rather than 0xffff.
Your fix looks good for me, although, I don't know if some vendors 
actually use 0 as valid UID.
Moreover, when I met this problem, I decided to move just this hack 
within the MAC driver  (as soon as the PHY is connected to the driver) 
instead of patching the PAL code.
Hoping this could be useful.
Ciao
 Peppe
