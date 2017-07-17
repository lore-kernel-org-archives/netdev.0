From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Mon, 17 Jul 2017 10:04:44 -0700
Message-ID: <20170717100444.00007077@intel.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
        <20170711173658.6188b0a2@redhat.com>
        <59650F6D.4070202@gmail.com>
        <20170711200136.46ab5687@redhat.com>
        <20170711204405.2f6b033c@redhat.com>
        <59651F55.9050203@gmail.com>
        <20170711211942.08fdd2f9@redhat.com>
        <596528E6.2080707@gmail.com>
        <20170716102308.163b9f91@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <andy@greyhouse.net>, <daniel@iogearbox.net>, <ast@fb.com>,
        <alexander.duyck@gmail.com>, <bjorn.topel@intel.com>,
        <jakub.kicinski@netronome.com>, <ecree@solarflare.com>,
        <sgoutham@cavium.com>, <Yuval.Mintz@cavium.com>,
        <saeedm@mellanox.com>, "Andi Kleen" <andi@firstfloor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38888 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751293AbdGQREr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 13:04:47 -0400
In-Reply-To: <20170716102308.163b9f91@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Jul 2017 10:23:08 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Tue, 11 Jul 2017 12:37:10 -0700 John Fastabend <john.fastabend@gmail.com> wrote:
> 
>  [...]  
> > 
> > hmm maybe Jesse or Alex have some clues. Adding them to the CC list.  
> 
> This seems related to Hyper-Threading.  I tried to disable
> hyperthreading in the BIOS, and the problem goes away.  That is, the
> benchmarks are no-longer affected by the CPU tuned-adm profile.

Wow, nice job figuring that out.  I went and took a look at tuned-adm
documentation but didn't see anything that stood out that would cause
the behavior you were seeing.

I suspect your toplev results showing this is a frontend problem mesh
nicely with the hyper-threading configuration inducing the bad behavior,
since there is still only one execution unit, and the fetchers would
have to stall.  I think you've rediscovered why the forwarding /
routing crowd generally turns off hyperthreading.
