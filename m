From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_CHECKSUM: avoid bad offload
 warnings on GSO packets
Date: Fri, 25 Aug 2017 11:40:25 +0200
Message-ID: <20170825094025.GJ15739@breakpoint.cc>
References: <20170824104824.2C318A0F3A@unicorn.suse.cz>
 <20170824105118.GA15739@breakpoint.cc>
 <20170824110742.qby3yoz3emf6pr5i@unicorn.suse.cz>
 <1503580122.2958.37.camel@redhat.com>
 <20170824131722.GB15739@breakpoint.cc>
 <20170825092819.hjgazfcvvrlibkd4@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Davide Caratti <dcaratti@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Markos Chandras <markos.chandras@suse.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825092819.hjgazfcvvrlibkd4@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek@suse.cz> wrote:
> On Thu, Aug 24, 2017 at 03:17:22PM +0200, Florian Westphal wrote:
> > Davide Caratti <dcaratti@redhat.com> wrote:
> > > Small nit: may I suggest you to call skb_csum_hwoffload_help() instead of
> > > skb_checksum_help(), so that we avoid corrupting SCTP packets in case they
> > > hit xt_CHECKSUM target?
> > 
> > Alternatively we could restrict the target to udp only.
> > 
> > AFAIU the only reason this thing exists is to fix up udp checksum
> > for old dhcp clients that use AF_PACKET without evaluating the extra
> > metadata that indicates when a 'bad' checksum is in fact ok because it
> > is supposed to be filled in by hardware later.
> > 
> > This can happen in virtual environemnt when such skb is directly passed
> > to vm.
> 
> Based on what the documentation and the commit message of the commit
> introducing xt_CHECKSUM module say, it seems so. But I must admit I'm
> not sure where is the target is used and how (and why). In particular,
> our issue was most likely result of
> 
>   https://github.com/openstack/openstack-ansible-tests/blob/master/test-prepare-host.yml#L196-L197

Sigh.  Ok, that pretty much leaves your patch as the only viable option,
however, I still think the warning isn't useful.

Can you send a v2 with gso check but without warning?

Thanks!
