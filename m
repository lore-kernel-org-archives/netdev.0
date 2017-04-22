From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: regenerate host route if moved to gc list
Date: Sat, 22 Apr 2017 08:14:16 -0600
Message-ID: <667a3b25-32a0-745f-a1a5-e76e2ffc7c8b@cumulusnetworks.com>
References: <1492818030-17640-1-git-send-email-dsa@cumulusnetworks.com>
 <20170422055703.uo4ghu5jfbctxvud@kafai-mba.dhcp.thefacebook.com>
 <CACT4Y+aRBZApshv2T-edaErPmiCsbMxNNkzC5Hs5jGJdvVwOAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        andreyknvl <andreyknvl@google.com>, mmanning@brocade.com
To: Dmitry Vyukov <dvyukov@google.com>, Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35391 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424182AbdDVOOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 10:14:37 -0400
Received: by mail-it0-f54.google.com with SMTP id 70so15373366ita.0
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 07:14:36 -0700 (PDT)
In-Reply-To: <CACT4Y+aRBZApshv2T-edaErPmiCsbMxNNkzC5Hs5jGJdvVwOAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/17 3:14 AM, Dmitry Vyukov wrote:
>> One small question.  Why cmpxchg is needed instead
>> of a ip6_rt_put() and then assign?
>> Is it fixing another bug?
> cmpxchg here looks fishy.
> If there are no concurrent modifications, then it is not needed.
> If there are and cmpxchg fails, then we will put the installed rt and
> leak the new one.
> 

Yes, I need to convert that to changing the rt under a lock.

Leftover from the beginning of the investigation when I suspected
locking and recalled Li's patch. I'll send a v2.
