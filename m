From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 11/12] bnxt_en: Add basic XDP support.
Date: Thu, 2 Feb 2017 15:57:54 -0800
Message-ID: <20170202235752.GA42563@ast-mbp.thefacebook.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <1486054540-366-12-git-send-email-michael.chan@broadcom.com>
 <20170202150813.4d94b306@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net,
        netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36568 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751720AbdBBX56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:57:58 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so296848pgf.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 15:57:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170202150813.4d94b306@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:08:27PM -0800, Jakub Kicinski wrote:
> > +	rcu_read_lock();
> > +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> > +	rcu_read_unlock();
> > +
> > +	if (orig_data != xdp.data) {
> > +		offset = xdp.data - xdp.data_hard_start;
> > +		len = xdp.data_end - xdp.data;
> 
> If BPF changed the start of the packet and returned XDP_PASS you should
> make sure stack will see the modified packet.  I.e. with adjusted
> offset and len.

that is correct.
skb passed to the stack should see new packet start and len.
Though today it's only useful with tc+cls_bpf on top that can
take advantage of it. Certainly more work is needed in this area
for xdp overall. I don't think we should mix that discussion
with this patch set.
