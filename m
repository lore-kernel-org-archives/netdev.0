From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 4/4] bpf: Add tests and samples for LWT-BPF
Date: Wed, 30 Nov 2016 07:52:05 +0100
Message-ID: <20161130065205.GC16856@pox.localdomain>
References: <cover.1480424542.git.tgraf@suug.ch>
 <25a6f8d0d56175bb27a05c18eb54bc3bc5c09fa1.1480424542.git.tgraf@suug.ch>
 <20161130001750.GB28238@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35099 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753128AbcK3GwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 01:52:08 -0500
Received: by mail-wm0-f47.google.com with SMTP id a197so259212610wmd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 22:52:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161130001750.GB28238@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 at 04:17pm, Alexei Starovoitov wrote:
> On Tue, Nov 29, 2016 at 02:21:23PM +0100, Thomas Graf wrote:
> > Adds a series of test to verify the functionality of attaching
> > BPF programs at LWT hooks.
> > 
> > Also adds a sample which collects a histogram of packet sizes which
> > pass through an LWT hook.
> > 
> > $ ./lwt_len_hist.sh
> > Starting netserver with host 'IN(6)ADDR_ANY' port '12865' and family AF_UNSPEC
> > MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.253.2 () port 0 AF_INET : demo
> > Recv   Send    Send
> > Socket Socket  Message  Elapsed
> > Size   Size    Size     Time     Throughput
> > bytes  bytes   bytes    secs.    10^6bits/sec
> > 
> >  87380  16384  16384    10.00    39857.69
> 
> Nice!
> 
> > +	ret = bpf_redirect(ifindex, 0);
> > +	if (ret < 0) {
> > +		printk("bpf_redirect() failed: %d\n", ret);
> > +		return BPF_DROP;
> > +	}
> 
> this 'if' looks a bit weird. You're passing 0 as flags,
> so this helper will always succeed.
> Other sample code often does 'return bpf_redirect(...)'
> due to this reasoning.

Right, the if branch is absolutely useless. I will remove it.
