From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: Neptune regression...
Date: Mon, 05 May 2008 13:10:50 -0700
Message-ID: <481F69CA.4070704@sun.com>
References: <20080503.235212.140840235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:63795 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbYEEUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 16:12:26 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m45KCOIl018607
	for <netdev@vger.kernel.org>; Mon, 5 May 2008 13:12:25 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K0E00801VXP0T00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Mon,
 05 May 2008 13:12:24 -0700 (PDT)
In-reply-to: <20080503.235212.140840235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Matheos, this patch of your's:
>
> commit 7f7c4072ea552f97a0898331322f71986a97299c
> Author: Matheos Worku <matheos.worku@sun.com>
> Date:   Thu Apr 24 21:02:37 2008 -0700
>
>     niu: Determine the # of ports from the card's VPD data
>     
>     [ Fix minor whitespace and coding style stuff... -DaveM ]
>     
>     Signed-off-by: Matheos Worku <matheos.worku@sun.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Breaks on-board Neptune chips on Maramba systems.
>
> Previously the code in niu_get_and_validate_port() used a default of
> "4" ports if the various probing methods failed.  Your code removed
> that fallback.
>
> This case seems to be what triggers for on-board Maramba chips.
>
> So, for now, I'm going to put the:
>
> 	if (!parent->num_ports)
> 		parent->num_ports = 4;
>
> back in there to fix the regression.  I've validated that this fixes
> the problem.
>
> Is there some other mechanism we should be using here to detect the
> port count in the Maramba on-board case?
>   
Dave,

Sorry I broke the driver.
I think the clean way to handle this would be to use the "board" 
property which exists for all Neptune variants, both in OBP properties  
as well as PCI VPD. I will work on the fix based on that approach  and 
will generate a patch as soon possible.
Regards
Matheos


