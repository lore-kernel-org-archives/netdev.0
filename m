From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 08:07:47 +0200
Message-ID: <1492668467.3109.4.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
         <1492640459.22185.7.camel@sipsolutions.net>
         <58F7FA6D.5030000@iogearbox.net>
         <20170420001218.GA38173@ast-mbp.thefacebook.com>
         <58F802EB.9080807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51314 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941212AbdDTGHw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:07:52 -0400
In-Reply-To: <58F802EB.9080807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 02:38 +0200, Daniel Borkmann wrote:

> > Since wifi skbs have only eth in headlen, there is not much
> > pointing adding support for data/data_end to wifi.
> > Just use ld_abs/ld_ind instructions and load_bytes() helper.
> 
> Afaik, the ld_abs/ld_ind are not an option due to the data
> on the wire being in little endian, but the bpf_skb_load_bytes()
> might be the way to go initially, agree.

Oh yeah, we could really only use byte loads which would be even less
efficient, so that's a good argument for not even providing the data
load instructions... :)

johannes
