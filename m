From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_CHECKSUM: avoid bad offload
 warnings on GSO packets
Date: Thu, 24 Aug 2017 15:17:22 +0200
Message-ID: <20170824131722.GB15739@breakpoint.cc>
References: <20170824104824.2C318A0F3A@unicorn.suse.cz>
 <20170824105118.GA15739@breakpoint.cc>
 <20170824110742.qby3yoz3emf6pr5i@unicorn.suse.cz>
 <1503580122.2958.37.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>, Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Markos Chandras <markos.chandras@suse.com>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503580122.2958.37.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davide Caratti <dcaratti@redhat.com> wrote:
> Small nit: may I suggest you to call skb_csum_hwoffload_help() instead of
> skb_checksum_help(), so that we avoid corrupting SCTP packets in case they
> hit xt_CHECKSUM target?

Alternatively we could restrict the target to udp only.

AFAIU the only reason this thing exists is to fix up udp checksum
for old dhcp clients that use AF_PACKET without evaluating the extra
metadata that indicates when a 'bad' checksum is in fact ok because it
is supposed to be filled in by hardware later.

This can happen in virtual environemnt when such skb is directly passed
to vm.
