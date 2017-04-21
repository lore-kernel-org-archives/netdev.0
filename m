From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from
 userspace
Date: Thu, 20 Apr 2017 17:16:50 -0700
Message-ID: <20170421001650.6f7g74tcs2h5hmuj@kafai-mba.dhcp.thefacebook.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
 <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com>
 <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
 <CAM_iQpVOGq_ePfuTdXWharY8taHrPtW4rEeqomhZ1R8g75nXTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38309 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S948245AbdDUAQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:16:54 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpVOGq_ePfuTdXWharY8taHrPtW4rEeqomhZ1R8g75nXTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 04:37:18PM -0700, Cong Wang wrote:
> On Thu, Apr 20, 2017 at 3:43 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> >
> > I scanned the others. It is not clear that others should fail with
> > EINVAL. Certainly a mask of unused flags can be added, but to me that is
> > on top of this bug fix.
> >
>
> If we want to preserve those unused bits, we should reject them too.
>
> RTF_PCPU is special here, it is used but only internally, so it makes
> sense to silently clear it since we don't care whether people set it to
> 1 or 0. We should clear it for dumping too since it is internal only.
I agree with DavidA. The existing bits (including RTF_PCPU) during dumping
is part of the uapi already.  We cannot stop displaying them now.

Silently accepting something instead of telling the userspace program
has a bug seems to be a dis-service to the end-user.

If there are other bits should be rejected too, they can be
done in the follow up patches.
