From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Sat, 2 Apr 2016 23:38:35 -0700
Message-ID: <20160403063834.GE21980@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459622455.18188.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35104 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcDCGik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 02:38:40 -0400
Received: by mail-pf0-f173.google.com with SMTP id n1so16396078pfn.2
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 23:38:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459622455.18188.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 08:40:55PM +0200, Johannes Berg wrote:
> On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:
> 
> > +static int mlx4_bpf_set(struct net_device *dev, int fd)
> > +{
> [...]
> > +		if (prog->type != BPF_PROG_TYPE_PHYS_DEV) {
> > +			bpf_prog_put(prog);
> > +			return -EINVAL;
> > +		}
> > +	}
> 
> Why wouldn't this check be done in the generic code that calls
> ndo_bpf_set()?
Having a common check makes sense. The tricky thing is that the type can
only be checked after taking the reference, and I wanted to keep the
scope of the prog brief in the case of errors. I would have to move the
bpf_prog_get logic into dev_change_bpf_fd and pass a bpf_prog * into the
ndo instead. Would that API look fine to you?

A possible extension of this is just to keep the bpf_prog * in the
netdev itself and expose a feature flag from the driver rather than an
ndo. But that would mean another 8 bytes in the netdev.
> 
> johannes
