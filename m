From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xt_CHECKSUM: avoid bad offload
 warnings on GSO packets
Date: Thu, 24 Aug 2017 15:08:42 +0200
Message-ID: <1503580122.2958.37.camel@redhat.com>
References: <20170824104824.2C318A0F3A@unicorn.suse.cz>
         <20170824105118.GA15739@breakpoint.cc>
         <20170824110742.qby3yoz3emf6pr5i@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Markos Chandras <markos.chandras@suse.com>
To: Michal Kubecek <mkubecek@suse.cz>, Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824110742.qby3yoz3emf6pr5i@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-24 at 13:07 +0200, Michal Kubecek wrote:
> On Thu, Aug 24, 2017 at 12:51:18PM +0200, Florian Westphal wrote:
> > Michal Kubecek <mkubecek@suse.cz> wrote:
> > > When --checksum_fill action is applied to a GSO packet, checksum_tg() calls
> > > skb_checksum_help() which is only meant to be applied to non-GSO packets so
> > > that it issues a warning.
> > > 
> > > This can be easily triggered by using e.g.
> > > 
> > >   iptables -t mangle -A OUTPUT -j CHECKSUM --checksum-fill
> > > 
> > > and sending TCP stream via a device with GSO enabled.
> > > 
> > > While this can be considered a misconfiguration, I believe the bad offload
> > > warning is supposed to catch bugs in drivers and networking stack, not
> > > misconfigured firewalls. So let's ignore such packets and only issue a one
> > > time warning with pr_warn_once() rather than a WARN with stack trace and
> > > tainted kernel.
> > 
> > Why issue a warning at all?
> > What kind of action should be taken upon seeing such warning?
> 
> Check and fix the configuration. The reason why I left at least some
> kind of warning is that the module does something that is unexpected as
> the checksum is not calculated (this module is often used in
> virtualization environments where "hardware checksum offload" in fact
> means the checksum is not computed at all).
> 

hello Michal,

GSO should be capable of computing the checksum on individual segments
later, so I also think the warning can be removed.

Small nit: may I suggest you to call skb_csum_hwoffload_help() instead of
skb_checksum_help(), so that we avoid corrupting SCTP packets in case they
hit xt_CHECKSUM target?

thank you in advance,
regards
-- 
davide
