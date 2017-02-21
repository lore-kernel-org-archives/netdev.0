From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] bpf: return errno -ENOMEM when exceeding
 RLIMIT_MEMLOCK
Date: Tue, 21 Feb 2017 14:00:13 +0100
Message-ID: <20170221140013.76afb3c2@redhat.com>
References: <148760491056.17885.7344022207445355578.stgit@firesoul>
        <58AB11EE.4050905@iogearbox.net>
        <20170220172558.3de0742d@redhat.com>
        <20170221080609.GA42330@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Daniel Borkmann <borkmann@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50596 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752100AbdBUNAS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 08:00:18 -0500
In-Reply-To: <20170221080609.GA42330@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Feb 2017 00:06:11 -0800
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Feb 20, 2017 at 05:25:58PM +0100, Jesper Dangaard Brouer wrote:
> > On Mon, 20 Feb 2017 16:57:34 +0100
> > Daniel Borkmann <daniel@iogearbox.net> wrote:
> >   
> > > On 02/20/2017 04:35 PM, Jesper Dangaard Brouer wrote:  
> > > > It is confusing users of samples/bpf that exceeding the resource
> > > > limits for RLIMIT_MEMLOCK result in an "Operation not permitted"
> > > > message.  This is due to bpf limits check return -EPERM.
> > > >
> > > > Instead return -ENOMEM, like most other users of this API.
> > > >
> > > > Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> > > > Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
> > > > Fixes: 5ccb071e97fb ("bpf: fix overflow in prog accounting")    
> > > 
> > > Btw, last one just moves the helper so fixes doesn't really apply
> > > there, but apart from that this is already uapi exposed behavior
> > > like this for ~1.5yrs, so unfortunately too late to change now. I
> > > think the original intention (arguably confusing in this context)
> > > was that user doesn't have (rlimit) permission to allocate this
> > > resource.  
> > 
> > This is obviously confusing end-users, thus it should be fixed IMHO.  
> 
> I don't think it's confusing and I think EPERM makes
> the most sense as return code in such situation.

Most other kernel users return ENOMEM.

> There is also code in iovisor/bcc that specifically looking
> for EPERM to adjust ulimit.

If there is already a program that depend on this, then it is ABI and
we cannot change it... drop this patch.

> May be it's not documented properly, but that's different story.

Documented it here:
 https://prototype-kernel.readthedocs.io/en/latest/bpf/troubleshooting.html

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
