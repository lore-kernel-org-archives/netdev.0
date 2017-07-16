From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Sun, 16 Jul 2017 10:23:08 +0200
Message-ID: <20170716102308.163b9f91@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        Andi Kleen <andi@firstfloor.org>, jesse.brandeburg@intel.com,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbdGPIXS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Jul 2017 04:23:18 -0400
In-Reply-To: <596528E6.2080707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 11 Jul 2017 12:37:10 -0700 John Fastabend <john.fastabend@gmail.com> wrote:

> > I have a really strange observation... if I change the CPU powersave
> > settings, then the xdp_redirect_map performance drops in half!  Above
> > was with "tuned-adm profile powersave" (because, this is a really noisy
> > server, and I'm sitting next to it).  I can see that the CPU under-load
> > goes into "turbomode", rest going into low-power, including the
> > Hyper-thread siblings.
> > 
> > If I change the profile to: # tuned-adm profile network-latency
> > 
> > ifindex 6:   12964879 pkt/s
> > ifindex 6:   12964683 pkt/s
> > ifindex 6:   12961497 pkt/s
> > ifindex 6:   11779966 pkt/s <-- change to tuned-adm profile network-latency
> > ifindex 6:    6853959 pkt/s
> > ifindex 6:    6851120 pkt/s
> > ifindex 6:    6856934 pkt/s
> > ifindex 6:    6857344 pkt/s
> > ifindex 6:    6857161 pkt/s
> > 
> > The CPU efficiency goes from 2.35 to 1.24 insn per cycle.
> > 
> > John do you know some Intel people that could help me understand what
> > is going on?!? This is very strange...
> > 
> > I tried Andi's toplev tool, which AFAIK indicate that this is a
> > Frontend problem, e.g. in decoding the instructions?!?
> >   
> 
> hmm maybe Jesse or Alex have some clues. Adding them to the CC list.

This seems related to Hyper-Threading.  I tried to disable
hyperthreading in the BIOS, and the problem goes away.  That is, the
benchmarks are no-longer affected by the CPU tuned-adm profile.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
