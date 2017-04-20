From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from userspace
Date: Thu, 20 Apr 2017 16:37:18 -0700
Message-ID: <CAM_iQpVOGq_ePfuTdXWharY8taHrPtW4rEeqomhZ1R8g75nXTQ@mail.gmail.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
 <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com> <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Martin KaFai Lau <kafai@fb.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35770 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948120AbdDTXhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 19:37:39 -0400
Received: by mail-wr0-f196.google.com with SMTP id l44so9852498wrc.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 16:37:39 -0700 (PDT)
In-Reply-To: <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 3:43 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
> I scanned the others. It is not clear that others should fail with
> EINVAL. Certainly a mask of unused flags can be added, but to me that is
> on top of this bug fix.
>

If we want to preserve those unused bits, we should reject them too.

RTF_PCPU is special here, it is used but only internally, so it makes
sense to silently clear it since we don't care whether people set it to
1 or 0. We should clear it for dumping too since it is internal only.
