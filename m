From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [Devel] Re: [PATCH 5/5] make netlink user -> kernel interface
 synchronious
Date: Fri, 05 Oct 2007 20:56:29 +0400
Message-ID: <47066CBD.90307@gmail.com>
References: <20071005144844.GA7119@iris.sw.ru> <4706653B.3050000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, containers@lists.osdl.org,
	netdev@vger.kernel.org, davem@davemloft.net, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:46952 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754252AbXJEQzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 12:55:06 -0400
Received: by nf-out-0910.google.com with SMTP id g13so710016nfb
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2007 09:55:04 -0700 (PDT)
In-Reply-To: <4706653B.3050000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Denis V. Lunev wrote:
>> This patch make processing netlink user -> kernel messages synchronious.
>> This change was inspired by the talk with Alexey Kuznetsov about current
>> netlink messages processing. He says that he was badly wrong when introduced 
>> asynchronious user -> kernel communication.
>>
>> The call netlink_unicast is the only path to send message to the kernel
>> netlink socket. But, unfortunately, it is also used to send data to the
>> user.
>>
>> Before this change the user message has been attached to the socket queue
>> and sk->sk_data_ready was called. The process has been blocked until all
>> pending messages were processed. The bad thing is that this processing
>> may occur in the arbitrary process context.
>>
>> This patch changes nlk->data_ready callback to get 1 skb and force packet
>> processing right in the netlink_unicast.
> 
> 
> I guess the process credential stuff in netlink_skb_params can now
> be removed as well.

Yes, but I think the patch should be tested by more people before.

Regards,
    Den
