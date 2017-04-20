From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 08:06:52 +0200
Message-ID: <1492668412.3109.3.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
         <1492640459.22185.7.camel@sipsolutions.net>
         <58F7FA6D.5030000@iogearbox.net>
         <20170420001218.GA38173@ast-mbp.thefacebook.com>
         (sfid-20170420_021226_941694_C014E347)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51260 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941127AbdDTGHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:07:03 -0400
In-Reply-To: <20170420001218.GA38173@ast-mbp.thefacebook.com> (sfid-20170420_021226_941694_C014E347)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 17:12 -0700, Alexei Starovoitov wrote:
> 
> also didn't we discuss that wifi has crazy non-linear skb?

Not always, depends on the driver.

But also, you have to remember that this filter would be before the
conversion to Ethernet header. Right now, when packets enter the stack,
we always linearize the 802.11 header - or even the whole frame for the
(rare) management packets. We don't do this before monitor mode and
before this filter right now, but there's no super good reason we can't
(it was just so we still report there in case of allocation failures.)

> this data/data_end is used by cls_bpf with headlen only
this data/data_end is used by cls_bpf with headlen only
> for direct packet access where performance matters.

Well performance does matter, though perhaps not as much - the people
I'd think could be the first to use this were adding code way after
doing many function calls, so ... :)

> Since wifi skbs have only eth in headlen, there is not much
> pointing adding support for data/data_end to wifi.
> Just use ld_abs/ld_ind instructions and load_bytes() helper.

You guys just told me not to support the skb access instructions ;-)

But yeah I have the load_bytes helper working. Just thought it might be
nice to get more. But we can also leave that for later.

johannes
