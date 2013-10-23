From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill
 struct tcp_memcontrol"
Date: Wed, 23 Oct 2013 23:07:43 +0100
Message-ID: <20131023220743.GA5226@localhost>
References: <20131022214129.GB2715@localhost>
 <20131022.180023.1141845387743361648.davem@davemloft.net>
 <87k3h461ql.fsf@tw-ebiederman.twitter.com>
 <20131023122543.GH5132@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131023122543.GH5132@cpaasch-mac>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -       return !!sk->sk_prot->memory_pressure;
> +       return !!*sk->sk_prot->memory_pressure;

Good catch, Christoph! With no surprise, it restores the performance:

    a4fe34bf902b8f709c63      2e685cad57906e19add7      a235435d612680e595ea  
------------------------  ------------------------  ------------------------  
                  707.40       -41.0%       417.50        -8.8%       645.00  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
                 2775.60       -23.7%      2116.50        +2.1%      2834.00  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
                 3483.00       -27.2%      2534.00        -0.1%      3479.00  TOTAL netperf.Throughput_Mbps

It's a bit late, but

Tested-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks,
Fengguang
