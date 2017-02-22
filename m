From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Questions on XDP
Date: Wed, 22 Feb 2017 22:59:24 +0100
Message-ID: <20170222225924.59cdd82c@redhat.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
        <58A8DD34.5040205@gmail.com>
        <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
        <20170221031829.GA3960@ast-mbp.thefacebook.com>
        <58ABB66D.60902@gmail.com>
        <CAKgT0UciU7sJrSqYKaCNK1iLD72WLcw=pRW5BMukCc99K5a0PQ@mail.gmail.com>
        <20170221075523.GA29348@ast-mbp.thefacebook.com>
        <CAKgT0UdFo1kKdPV=bL8m_y+o37t+m9NNesA8XAUE8pCtcexUaw@mail.gmail.com>
        <58ADC5A5.7020408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59100 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754455AbdBVWAw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 17:00:52 -0500
In-Reply-To: <58ADC5A5.7020408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2017 09:08:53 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> > GSO/TSO is getting into advanced stuff I would rather not have to get
> > into right now.  I figure we need to take this portion one step at a
> > time.  To support GSO we need more information like the mss.
> >   
> 
> Agreed lets get the driver support for basic things first. But this
> is on my list. I'm just repeating myself but VM to VM performance uses
> TSO/LRO heavily.

Sorry, but I get annoyed every time I hear we need to support
TSO/LRO/GRO for performance reasons.  If you take one step back, you
are actually saying we need bulking for better performance.  And the
bulking you are proposing is a TCP protocol specific bulking mechanism.

I'm saying is let's make bulking protocol agnostic, by doing it at the
packet level.  And once the bulk enters the VM, by-all-means it should
construct a GRO packet it can send into it's own network stack.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
