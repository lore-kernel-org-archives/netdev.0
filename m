From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Tue, 21 Sep 2010 08:14:01 +0800
Message-ID: <AANLkTint-pWd2vBsHHcc_i77V20GOrHwLo32b_=GX2EO@mail.gmail.com>
References: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
 <AANLkTinyZxF4ep7tv_uSpcPD8gfNoddX6G7p+ZuA2ze9@mail.gmail.com> <AANLkTi=53F3O511Uq83dP75brGkJMgN_-OR9W0VJS1p-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58779 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab0IUAWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 20:22:31 -0400
Received: by wyf22 with SMTP id 22so4902188wyf.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 17:22:30 -0700 (PDT)
In-Reply-To: <AANLkTi=53F3O511Uq83dP75brGkJMgN_-OR9W0VJS1p-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 21, 2010 at 1:50 AM, Tom Herbert <therbert@google.com> wrote:
>
>>
>> > On the server side it works well if there are a sufficient
>> > number of requests coming on the connection (resorting to the
>> > timeout if necessary as described above).
>>
>> If no response is sent out by the client, the timeout mechanism may
>> slow down the data transfer.
>>
> Why would that slow down a transfer?


vmsplice(sock, page).
epoll(sock.read_event, timeo);
/* time out */
if_the_page_is_available.
  reclaim_page_and_send_the_next_data.

The page maybe available before timeout, and you may not send the next
data in time.



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
