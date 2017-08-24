From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_CHECKSUM: avoid bad offload
 warnings on GSO packets
Date: Thu, 24 Aug 2017 12:51:18 +0200
Message-ID: <20170824105118.GA15739@breakpoint.cc>
References: <20170824104824.2C318A0F3A@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Markos Chandras <markos.chandras@suse.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824104824.2C318A0F3A@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek@suse.cz> wrote:
> When --checksum_fill action is applied to a GSO packet, checksum_tg() calls
> skb_checksum_help() which is only meant to be applied to non-GSO packets so
> that it issues a warning.
> 
> This can be easily triggered by using e.g.
> 
>   iptables -t mangle -A OUTPUT -j CHECKSUM --checksum-fill
> 
> and sending TCP stream via a device with GSO enabled.
> 
> While this can be considered a misconfiguration, I believe the bad offload
> warning is supposed to catch bugs in drivers and networking stack, not
> misconfigured firewalls. So let's ignore such packets and only issue a one
> time warning with pr_warn_once() rather than a WARN with stack trace and
> tainted kernel.

Why issue a warning at all?
What kind of action should be taken upon seeing such warning?
