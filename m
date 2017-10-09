From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of
 'xt_bpf_info_v1'
Date: Mon, 9 Oct 2017 13:57:36 +0200
Message-ID: <20171009115736.GA31826@salvia>
References: <20171006160242.4403-1-shmulik@nsof.io>
 <CAF=yD-JbZ_ViWsBWK7Ye=4RYF9BgnMKvD04xE5P26RNRpnmuiQ@mail.gmail.com>
 <20171009111823.GA30637@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Shmulik Ladkani <shmulik@nsof.io>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Rafael Buchbinder <rafi@rbk.ms>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:40199 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdJIL5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 07:57:42 -0400
Content-Disposition: inline
In-Reply-To: <20171009111823.GA30637@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 01:18:23PM +0200, Pablo Neira Ayuso wrote:
> On Fri, Oct 06, 2017 at 01:40:13PM -0400, Willem de Bruijn wrote:
> > On Fri, Oct 6, 2017 at 12:02 PM, Shmulik Ladkani <shmulik@nsof.io> wrote:
> > > From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > >
> > > Commit 2c16d6033264 ("netfilter: xt_bpf: support ebpf") introduced
> > > support for attaching an eBPF object by an fd, with the
> > > 'bpf_mt_check_v1' ABI expecting the '.fd' to be specified upon each
> > > IPT_SO_SET_REPLACE call.
> > >
> > > However this breaks subsequent iptables calls:
> > >
> > >  # iptables -A INPUT -m bpf --object-pinned /sys/fs/bpf/xxx -j ACCEPT
> > >  # iptables -A INPUT -s 5.6.7.8 -j ACCEPT
> > >  iptables: Invalid argument. Run `dmesg' for more information.
> [...]
> > >
> > > References: [1] https://marc.info/?l=netfilter-devel&m=150564724607440&w=2
> > >             [2] https://marc.info/?l=netfilter-devel&m=150575727129880&w=2
> > >
> > > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > > Cc: Willem de Bruijn <willemb@google.com>
> > > Reported-by: Rafael Buchbinder <rafi@rbk.ms>
> > > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > 
> > Acked-by: Willem de Bruijn <willemb@google.com>
> 
> Applied, thanks.

Hm, I have to keep this back. Compilation breaks here.

net/netfilter/xt_bpf.c: In function ‘__bpf_mt_check_path’:
net/netfilter/xt_bpf.c:59:2: error: implicit declaration of function
‘bpf_obj_get_user’ [-Werror=implicit-function-declaration]
  fd = bpf_obj_get_user(path);
  ^
