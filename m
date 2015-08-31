From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 11:40:30 -0600
Message-ID: <55E4918E.7030104@cumulusnetworks.com>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
 <CALx6S379ZrcKdapJ0yRwzyW-ACY=45DcJnUNJ6mRZPjJAie1VA@mail.gmail.com>
 <55E4895D.2060202@cumulusnetworks.com>
 <CALx6S36YTzCRDQUArzDv5sXHc6wgKxFnxNAauAGj74R_nYQabA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35412 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbbHaRkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:40:42 -0400
Received: by igbut12 with SMTP id ut12so27936222igb.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:40:41 -0700 (PDT)
In-Reply-To: <CALx6S36YTzCRDQUArzDv5sXHc6wgKxFnxNAauAGj74R_nYQabA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom:

On 8/31/15 11:22 AM, Tom Herbert wrote:
> It's a major departure from current convention. The source address of
> the packet should be set before doing ip_send_skb. In UDP unconnected
> case ip_route_output_flow calls inet_select_addr. AKAIK there is no
> provision for not setting the source address and relying on the output
> device to do this in its transmit routine. I still think it would be
> better to call into the VRF device from inet_select_addr using an ndo
> function.

I was not disregarding your suggestion and definitely appreciate the 
advice. I will look into it in time. In fact I was looking at how to 
better encapsulate FIB oif changes (e.g., with ndo) on the plane home 
yesterday, but those take time and seem more appropriate for 4.4.

My intention with this patch is to reign in the VRF footprint and by 
extension impact for 4.3 without losing functionality. During the merge 
window for 4.3 net-next will be closed and it provides a good time to 
investigate abstractions like ndo handlers.

David
