From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Sun, 3 Apr 2016 00:02:22 -0700
Message-ID: <20160403070221.GF21980@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <CALx6S35N1W32e9fvAmEbPdZk1PK2eNUgd0uU7pteMkBoHUd36g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	ogerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33067 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcDCHC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 03:02:26 -0400
Received: by mail-pf0-f169.google.com with SMTP id 184so21630712pff.0
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 00:02:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35N1W32e9fvAmEbPdZk1PK2eNUgd0uU7pteMkBoHUd36g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 12:39:45PM -0400, Tom Herbert wrote:
> On Fri, Apr 1, 2016 at 9:21 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > Add a new bpf prog type that is intended to run in early stages of the
> > packet rx path. Only minimal packet metadata will be available, hence a new
> > context type, struct xdp_metadata, is exposed to userspace. So far only
> > expose the readable packet length, and only in read mode.
> >
> This would eventually be a generic abstraction of receive descriptors?
Exactly. For instance, maybe let the hw's hash be available.
> 
> > The PHYS_DEV name is chosen to represent that the program is meant only
> > for physical adapters, rather than all netdevs.
> >
> Is there a hard restriction that this could only work with physical devices?
I suppose not, but there wouldn't be much use case as compared to tc
ingress, no? Since I was imagining that this new hook would be more
restricted in functionality due to operating on descriptors rather than
with a full skb, I tried to think of an appropriate name.

If you think that this hook would spread, then a better name is needed.
> 
[...]
