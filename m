From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] bpf: return errno -ENOMEM when exceeding
 RLIMIT_MEMLOCK
Date: Mon, 20 Feb 2017 17:25:58 +0100
Message-ID: <20170220172558.3de0742d@redhat.com>
References: <148760491056.17885.7344022207445355578.stgit@firesoul>
        <58AB11EE.4050905@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdBTQ0C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 11:26:02 -0500
In-Reply-To: <58AB11EE.4050905@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Feb 2017 16:57:34 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 02/20/2017 04:35 PM, Jesper Dangaard Brouer wrote:
> > It is confusing users of samples/bpf that exceeding the resource
> > limits for RLIMIT_MEMLOCK result in an "Operation not permitted"
> > message.  This is due to bpf limits check return -EPERM.
> >
> > Instead return -ENOMEM, like most other users of this API.
> >
> > Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> > Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
> > Fixes: 5ccb071e97fb ("bpf: fix overflow in prog accounting")  
> 
> Btw, last one just moves the helper so fixes doesn't really apply
> there, but apart from that this is already uapi exposed behavior
> like this for ~1.5yrs, so unfortunately too late to change now. I
> think the original intention (arguably confusing in this context)
> was that user doesn't have (rlimit) permission to allocate this
> resource.

This is obviously confusing end-users, thus it should be fixed IMHO.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
