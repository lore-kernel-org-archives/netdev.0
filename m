From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] pptp: validate sockaddr_len before binding
Date: Tue, 15 Dec 2015 00:33:21 +0100
Message-ID: <566F51C1.7000600@stressinduktion.org>
References: <1450133128-18845-1-git-send-email-hannes@stressinduktion.org>
 <CAHA+R7MBjZ5HzHkag6i-bQH=6LMveN8gQaJ6OT-MAZXJtv1HjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39924 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753605AbbLNXdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 18:33:25 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 1B8DA216BB
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 18:33:24 -0500 (EST)
In-Reply-To: <CAHA+R7MBjZ5HzHkag6i-bQH=6LMveN8gQaJ6OT-MAZXJtv1HjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.12.2015 23:58, Cong Wang wrote:
> On Mon, Dec 14, 2015 at 2:45 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
>> index fc69e41d09506e..f9ffdf070ad807 100644
>> --- a/drivers/net/ppp/pptp.c
>> +++ b/drivers/net/ppp/pptp.c
>> @@ -419,6 +419,9 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
>>         struct pptp_opt *opt = &po->proto.pptp;
>>         int error = 0;
>>
>> +       if (sockaddr_len < sizeof(*sp))
>> +               return -EINVAL;
>> +
> 
> I sent a very similar patch:
> https://patchwork.ozlabs.org/patch/556663/

Ah, thanks. Did not notice. The connect() part is also already in my
queue, but I don't think it solves the use-after-free. The RCU
implementation of callid_sock seems broken to me.

David, discard my patch.

Thanks,
Hannes
