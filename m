From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 15:22:11 -0800
Message-ID: <1488324131.9415.278.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
         <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
         <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
         <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
         <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
         <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com>
         <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33717 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdB1XWT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 18:22:19 -0500
In-Reply-To: <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 14:52 -0800, Andy Lutomirski wrote:

> The user pages are a gift to the kernel.  The application  may  not
> modify this memory ever, otherwise the page cache and on-disk data may
> differ.
> 
> This is just not okay IMO.

TCP works just fine in this case.

TX checksum will be computed by the NIC after/while data is copied.

If really the application changes the data, that will not cause any
problems, other than user side consistency.

This is why we require a copy (for all buffers that came from zero-copy)
if network stack hits a device that can not offload TX checksum.

Even pwrite() does not guarantee consistency if multiple threads are
using it on overlapping regions.
