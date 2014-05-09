From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 75571] New: using tc action mirred results BUG at net/core/skbuff.c:119
Date: Fri, 9 May 2014 11:31:52 -0700
Message-ID: <CAHA+R7OG0qqr4Q2cFomY0CKH6DP+J==ii_G--d6FzcTScB6iEA@mail.gmail.com>
References: <20140506081628.1626ff94@nehalam.linuxnetplumber.net>
	<CAHA+R7NX639wxkvvrqP=ogeiAwDeJYDnFp_z_VqB3yqh8KLjFA@mail.gmail.com>
	<536B58D7.2070009@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>, d77190@mail.ru
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:48054 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063AbaEISby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 14:31:54 -0400
Received: by mail-la0-f54.google.com with SMTP id pv20so155665lab.27
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 11:31:52 -0700 (PDT)
In-Reply-To: <536B58D7.2070009@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 3:13 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Hi Cong,
>
> Sorry for the latency - on travel mode.
>
>
> On 05/06/14 18:30, Cong Wang wrote:
>>
>> On Tue, May 6, 2014 at 8:16 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>
>
>>
>> Hmm, looks like we pushed wrong header size here. tcf_mirred_init()
>> checks if we could push hard header by checking the type of the target
>> device,
>> while in tcf_mirred() we push the ->hard_header_len of the source device
>> where this skb is received. I am not sure at all.
>>
>> Jamal, does the following patch make any sense for you?
>>
>
> Dont feel like that patch would help. Scratching my head....
> One way to tell is to: ifconfig down the source (which seems like tunnel
> device) and install all the rules then last step is ifconfig first ifb,
> then the tunnel device. And if it works with current kernel patch is not
> needed. It feels like some race condition between installing
> rule and using it i.e rule gets installed and when still trying to
> advertise to user space, a packet arrives and starts using it.
> If the above works - then the question to d77190@mail.ru is what kernel
> this is and when did this last work as installed?

It's an old kernel, 3.2.58. :-/

Please try to reproduce it on the latest kernel if possible.
