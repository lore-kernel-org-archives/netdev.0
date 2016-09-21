From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 1/2] e1000: add initial XDP support
Date: Tue, 20 Sep 2016 21:30:36 -0700
Message-ID: <57E20CEC.4040600@gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <CAD=hENf9UZppBSx11Pdg8A9U2tmNLYOXeY5tpzyYiBF4dOcGLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>, brouer@redhat.com,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        u9012063@gmail.com, netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34116 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbcIUEa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:30:57 -0400
Received: by mail-pa0-f65.google.com with SMTP id s3so364835pay.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 21:30:57 -0700 (PDT)
In-Reply-To: <CAD=hENf9UZppBSx11Pdg8A9U2tmNLYOXeY5tpzyYiBF4dOcGLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-20 09:26 PM, zhuyj wrote:
>  +static int e1000_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
> +{
> +       struct e1000_adapter *adapter = netdev_priv(netdev);
> +       struct bpf_prog *old_prog;
> +
> +       old_prog = xchg(&adapter->prog, prog);
> +       if (old_prog) {
> +               synchronize_net();
> +               bpf_prog_put(old_prog);
> +       }
> +
> +       if (netif_running(netdev))
> +               e1000_reinit_locked(adapter);
> +       else
> +               e1000_reset(adapter);
> +       return 0;
> +}
> 
> To this function, is it better to use "static void
> e1000_xdp_set(struct net_device *netdev, struct bpf_prog *prog)"?
> since it is always to return 0.
> 

In general try to avoid top posting.

Yes making it void would be reasonable and probably a good idea. I'll
do it in v3.

[...]

Thanks,
John
