From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from
 userspace
Date: Thu, 20 Apr 2017 16:43:03 -0600
Message-ID: <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
 <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Martin KaFai Lau <kafai@fb.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35213 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030888AbdDTWnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:43:07 -0400
Received: by mail-io0-f176.google.com with SMTP id r16so86567569ioi.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:43:07 -0700 (PDT)
In-Reply-To: <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/17 4:39 PM, Cong Wang wrote:
> On Wed, Apr 19, 2017 at 2:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>
>> Fix by checking for the flag and failing with EINVAL.
>>
> 
> I am still not sure about this. There are a few unused bits in
> this flag, we simply ignore the rest, right? Why should we
> reject this one instead of all of those we don't use?
> 

RTF_PCPU most definitely should not be set by userspace. arguably it
should not be returned to userspace either, but it is part of the uapi.


I scanned the others. It is not clear that others should fail with
EINVAL. Certainly a mask of unused flags can be added, but to me that is
on top of this bug fix.
