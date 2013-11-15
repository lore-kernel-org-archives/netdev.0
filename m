From: John Hughes <john@atlantech.com>
Subject: Re: When a TCP segment is split up (to be sent through a TUN device
 with a small MTU) who should recalculate the checksum?
Date: Fri, 15 Nov 2013 15:31:59 +0100
Message-ID: <5286305F.5060903@atlantech.com>
References: <5285E0BC.4090402@atlantech.com> <52862DBF.2060801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Hughes <john@atlantech.com>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from olympic.calvaedi.com ([89.202.194.163]:47715 "EHLO
	olympic.calvaedi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3KOOcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 09:32:01 -0500
In-Reply-To: <52862DBF.2060801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/11/13 15:20, Vlad Yasevich wrote:
>
> Can you check to see if you have the following patch in your kernel
> commit: 1cdbcb7957cf9e5f841dbcde9b38fd18a804208b
> Author: Simon Horman <horms@verge.net.au>
> Date:   Sun May 19 15:46:49 2013 +0000
>
>     net: Loosen constraints for recalculating checksum in skb_segment()
>
>
> This commit help if the forwarding system has to re-segment the data
> before transition.  Especially if the receiving interface had GRO
> enabled with checksum offloading and the transmitting interface does
> not support checksum offloading.

No, the Debian 3.10 kernel doesn't seem to have that commit:

Around line 2859 in skbuff.c I see:

                 if (fskb != skb_shinfo(skb)->frag_list)
                         continue;
