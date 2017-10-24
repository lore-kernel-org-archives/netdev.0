From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Linux ECN Handling
Date: Mon, 23 Oct 2017 21:11:38 -0400
Message-ID: <CADVnQymmMeo=cemUPQCzHpNvFPKCaqY1+VPchmui+HWuCL7CuA@mail.gmail.com>
References: <CACJspmLFdy9i8K=TkzXHnofyFMNoJf9HkYE7On8uG+PREc2Dqw@mail.gmail.com>
 <20171019124312.GE16796@breakpoint.cc> <CACJspmKjAr+q9cFVssXVxWQMCUWe3TNYO77m0nQwzQK4hTCOzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Mohammad Alizadeh <alizadeh@csail.mit.edu>
To: Steve Ibanez <sibanez@stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:51743 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdJXBMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 21:12:00 -0400
Received: by mail-wr0-f179.google.com with SMTP id j15so6943737wre.8
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 18:12:00 -0700 (PDT)
In-Reply-To: <CACJspmKjAr+q9cFVssXVxWQMCUWe3TNYO77m0nQwzQK4hTCOzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 6:15 PM, Steve Ibanez <sibanez@stanford.edu> wrote:
> Hi All,
>
> I upgraded the kernel on all of our machines to Linux
> 4.13.8-041308-lowlatency. However, I'm still observing the same
> behavior where the source enters a timeout when the CWND=1MSS and it
> receives ECN marks.
>
> Here are the measured flow rates:
> <https://drive.google.com/file/d/0B-bt9QS-C3ONT0VXMUt6WHhKREE/view?usp=sharing>
>
> Here are snapshots of the packet traces at the sources when they both
> enter a timeout at t=1.6sec:
>
> 10.0.0.1 timeout event:
> <https://drive.google.com/file/d/0B-bt9QS-C3ONcl9WRnRPazg2ems/view?usp=sharing>
>
> 10.0.0.3 timeout event:
> <https://drive.google.com/file/d/0B-bt9QS-C3ONeDlxRjNXa0VzWm8/view?usp=sharing>
>
> Both still essentially follow the same sequence of events that I
> mentioned earlier:
> (1) receives an ACK for byte XYZ with the ECN flag set
> (2) stops sending for RTO_min=300ms
> (3) sends a retransmission for byte XYZ
>
> The cwnd samples reported by tcp_probe still indicate that the sources
> are reacting to the ECN marks more than once per window. Here are the
> cwnd samples at the same timeout event mentioned above:
> <https://drive.google.com/file/d/0B-bt9QS-C3ONdEZQdktpaW5JUm8/view?usp=sharing>
>
> Let me know if there is anything else you think I should try.

Sounds like perhaps cwnd is being set to 0 somewhere in this DCTCP
scenario. Would you be able to add printk statements in
tcp_init_cwnd_reduction(), tcp_cwnd_reduction(), and
tcp_end_cwnd_reduction(), printing the IP:port, tp->snd_cwnd, and
tp->snd_ssthresh?

Based on the output you may be able to figure out where cwnd is being
set to zero. If not, could you please post the printk output and
tcpdump traces (.pcap, headers-only is fine) from your tests?

thanks,
neal
