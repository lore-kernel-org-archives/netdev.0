From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 11:49:55 -0600
Message-ID: <55E493C3.1000102@cumulusnetworks.com>
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
Received: from mail-io0-f177.google.com ([209.85.223.177]:34969 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbHaRuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:50:02 -0400
Received: by iog7 with SMTP id 7so43285266iog.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:50:02 -0700 (PDT)
In-Reply-To: <CALx6S36YTzCRDQUArzDv5sXHc6wgKxFnxNAauAGj74R_nYQabA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/15 11:22 AM, Tom Herbert wrote:
> It's a major departure from current convention. The source address of
> the packet should be set before doing ip_send_skb. In UDP unconnected
> case ip_route_output_flow calls inet_select_addr. AKAIK there is no
> provision for not setting the source address and relying on the output
> device to do this in its transmit routine.

BTW, one other clarification the code setting the source address is NOT 
in the xmit function but the dst.output function. The VRF device uses a 
dst to direct packets to it. The output function (equivalent to 
ip_output) is what sets the source address if necessary.
