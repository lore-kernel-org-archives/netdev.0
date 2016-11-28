From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net/sctp: vmalloc allocation failure in
 sctp_setsockopt/xt_alloc_table_info
Date: Mon, 28 Nov 2016 12:56:26 -0500
Message-ID: <20161128175626.GD29839@hmsreliant.think-freely.org>
References: <CAAeHK+wecw6ST_DWJQBLFNwVsOVgderGE-EEJiN0-kf796XHtw@mail.gmail.com>
 <20161128141340.GA29839@hmsreliant.think-freely.org>
 <CAAeHK+xJmwF6hddS-sO-y3HQkRicwQN=ZceFWTZT2M_0h4E2hQ@mail.gmail.com>
 <20161128143931.GB29839@hmsreliant.think-freely.org>
 <20161128151312.GA13172@localhost.localdomain>
 <20161128174647.GC29839@hmsreliant.think-freely.org>
 <20161128174710.GE28510@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57262 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbcK1R4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:56:45 -0500
Content-Disposition: inline
In-Reply-To: <20161128174710.GE28510@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 06:47:10PM +0100, Florian Westphal wrote:
> Neil Horman <nhorman@tuxdriver.com> wrote:
> > I'm not sure I agree with that.  Generally speaking it seems like the right
> > thing to do, if you want to avoid filling logs with warnings, but this is the
> > sort of error that is going to be accompanied by severe service interruption.
> > I'd rather see a reason behind that in the logs, than just have it occur
> > silently.
> 
> Its not silent -- the setsockopt call will fail and userspace should
> display an error.
> 
Thats not true.  If the OOM succedes in freeing enough memory to fulfill the
request the setsockopt may complete without error, you're just left with a
killed process...somewhere.  Thats seems a bit dodgy to me

Not saying it has to be a full stack trace, but some log annotation that shows
the oom killer got invoked seems called for here

Neil

> So I agree with Marcelo, lets suppress the oom spew here.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
