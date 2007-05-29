From: "Lior Dotan" <liodot@gmail.com>
Subject: Re: [PATCH-2.4] Fix divide by 0 in vegas_cong_avoid()
Date: Tue, 29 May 2007 20:23:45 +0200
Message-ID: <a5bf86a80705291123r7aa753besbcb1de3f13dc1b3c@mail.gmail.com>
References: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
	 <20070529080534.5692bad8@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:40724 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521AbXE2SXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 14:23:46 -0400
Received: by wa-out-1112.google.com with SMTP id j4so923037wah
        for <netdev@vger.kernel.org>; Tue, 29 May 2007 11:23:46 -0700 (PDT)
In-Reply-To: <20070529080534.5692bad8@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NTP was not running. I'm not sure what do you mean by fixing the -1.
The trace shows that vegas_cong_avoid() is called with -1, and the
only way it can happen is from tcp_clean_rtx_queue() and the patch
should eliminate this. Another way of solving this is by checking
vegas_rtt_calc() and see if it gets -1 and handle it there.
Another thing that I don't understand is that some places like
tcp_ack() declare seq_rtt as signed and some vegas_cong_avoid()
declare it as unsigned. Shouldn't it be declared always as signed?

On 5/29/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Tue, 29 May 2007 12:18:19 +0300
> "Lior Dotan" <liodot@gmail.com> wrote:
>
> > Hi,
> >
> > I had a divide by zero on kernel 2.4.33 running with Vegas enabled.
> > The KDB back trace is:
> > kdb> bt
> > Stack traceback for pid 0
> > 0x403a6000        0        0  1    0   R  0x403a6370 *swapper
> > EBP        EIP        Function (args)
> > 0x403a7d48 0x4026ae51 vegas_cong_avoid+0x111 (0x5f3bb638, 0x73c92cbb, 0xffffffff
> > , 0x73c92cbb, 0xf28d0275)
> >                                kernel .text 0x40100000 0x4026ad40 0x4026aef0
> > 0x403a7d8c 0x4026bb67 tcp_ack+0x307 (0x5f3bb560, 0x581985c0, 0x18e, 0x4023e765,
> > 0x5c369044)
> >                                kernel .text 0x40100000 0x4026b860 0x4026be20
>
>
> Seems like fixing the -1 would be better.  Perhaps NTP reset
> the clock?
>
>
>
> --
> Stephen Hemminger <shemminger@linux-foundation.org>
>
