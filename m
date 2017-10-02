From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 0/2] net/sched: support tunnel options in
 cls_flower and act_tunnel_key
Date: Mon, 2 Oct 2017 09:50:15 +0200
Message-ID: <20171002075013.GA22179@netronome.com>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
 <20170929.055423.108055524887949393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:49808 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdJBHuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 03:50:17 -0400
Received: by mail-wm0-f51.google.com with SMTP id b189so4909780wmd.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 00:50:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170929.055423.108055524887949393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 05:54:23AM +0100, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Wed, 27 Sep 2017 10:16:32 +0200
> 
> > Users of options:
> > 
> > * There are eBPF hooks to allow getting on and setting tunnel metadata:
> >   bpf_skb_set_tunnel_opt, bpf_skb_get_tunnel_opt.
> > 
> > * Open vSwitch is able to match and set Geneve and VXLAN-GBP options.
> > 
> > Neither of the above appear to assume any structure for the data.
> 
> I really worry about this.
> 
> These metadata option blobs are internal kernel datastructure which we
> could change at any point in time.  They are not exported to
> userspace as a UAPI.
> 
> It's kinda OK for eBPF programs to access this stuff since they are
> expected to cope with changes to internal data-structures.
> 
> But for anything user facing, this really doesn't work.

Hi Dave, Hi Jiri,

the feedback I got from Jiri is that there needs to be some exposure
of TLVs. What I have in mind is to describe Geneve option TLVs in the
UAPI and for the kernel - most likely cls_flower, possibly using helpers,
to translate between that encoding and the one used internally by the kernel
- which currently happens to be the on-the-wire format.

I believe that in order to avoid per-packet overhead and at the same time
code complexity the TLVs should be described in-order. So matching on
TLV-A,TLV-B,TLV-C would be a different match to TLV-C,TLV-A,TLV-B.  An
order-independent match could be added if desired in future.

This would mean the feature is initially restricted to Geneve but could
be expended to offer a similar feature for other encapsulation protocols
as the need arises.

Would this address your concerns?
