From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: qualcomm: rmnet: Support recycling frames
 to real device
Date: Fri, 27 Oct 2017 18:19:13 -0700
Message-ID: <CAKgT0UfDRavM+vNiegMyDiDNiuTt2wg39J9L_S2AepV3eVVgKA@mail.gmail.com>
References: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
 <CAKgT0Ufnupf=fUbivLWrMhmfkcx4f0ApZ7gS_9VK7P7J8zB1aw@mail.gmail.com> <e5781ccadd670fd3ddf07f0e3fff1256@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:54817 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdJ1BTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 21:19:15 -0400
Received: by mail-qt0-f196.google.com with SMTP id z19so10480855qtg.11
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 18:19:14 -0700 (PDT)
In-Reply-To: <e5781ccadd670fd3ddf07f0e3fff1256@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 3:22 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
>> This doesn't make sense to me, maybe I am missing something. What
>> "real device" is setting the skb->destructor() and doing it to somehow
>> handle recycling? The only driver I can find that is setting
>> skb->desctructor() is the Chelsio drivers, and they appear to be using
>> it to just clean-up DMA mappings in their transmit path.
>>
>> Thanks.
>>
>> - Alex
>
>
> Hi Alex
>
> The real device will have a pool of skbs and mark them as unused on
> initialization. It will use these skbs to copy data from hardware and
> pass them onto rmnet after marking them as used. Once rmnet is done
> processing, the callback of the real device set in the skb_destructor
> is invoked and the skb is set as unused and can be used again for
> copying data.

There is a pretty big difference between calling skb->destructor() and
freeing the buffer. My concern would be how do you deal with the
reference count issues that is going to bring up?

> There are no drivers setting the skb->destructor() in receive path
> upstream as of now but the plan is to get them there.

Okay. Got it.

Thanks.

- Alex
