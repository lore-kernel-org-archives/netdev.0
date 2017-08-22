From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 10:09:15 -0700
Message-ID: <20170822170913.35umf4j6hlmcnwtm@ast-mbp>
References: <20170821212506.1cb0d5d6@redhat.com>
 <20170821223540.atktdricmks26c27@ast-mbp>
 <20170822083710.47a182a2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36581 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHVRJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:09:18 -0400
Content-Disposition: inline
In-Reply-To: <20170822083710.47a182a2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 08:37:10AM +0200, Jesper Dangaard Brouer wrote:
> 
> 
> > Once tx-ing netdev added to devmap we can enable xdp on it automatically?
> 
> I think you are referring to Gotcha-2 here:

oops. yes :)

> 
>   Second gotcha(2): you cannot TX out a device, unless it also have a
>   xdp bpf program attached. (This is an implicit dependency, as the
>   driver code need to setup XDP resources before it can ndo_xdp_xmit).
> 
> Yes, we should work on improving this situation.  Auto enabling XDP
> when a netdev is added to a devmap is a good solution.  Currently this
> is tied to loading an XDP bpf_prog.  Do you propose loading a dummy
> bpf_prog on the netdev? (then we need to handle 1. not replacing
> existing bpf_prog, 2. on take-down don't remove "later" loaded
> bpf_prog).

right. these things need to be taken care of.
Technically for ndo_xdp_xmit to work the program doesn't need
to be attached, but the device needs to be in xdp mode with
configured xdp tx rings.
The easiest, of course, is just to document it :)
and may be add some sort of warning that if netdev is added
to devmap and it's not in xdp mode, return warning or error.
