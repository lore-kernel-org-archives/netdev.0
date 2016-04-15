From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Fri, 15 Apr 2016 11:38:53 +0200
Message-ID: <1460713133.7410.2.camel@redhat.com>
References: <cover.1459934322.git.pabeni@redhat.com>
	 <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
	 <20160406234532.GA731@breakpoint.cc> <2239567.jkCk1gtQAE@sifl>
	 <1460451162.5965.16.camel@redhat.com>
	 <CAHC9VhSgWAoWgywOZOvT76jCcHuEywjFu5CKJo9D0k+66RbFCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Florian Westphal <fw@strlen.de>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAHC9VhSgWAoWgywOZOvT76jCcHuEywjFu5CKJo9D0k+66RbFCA@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-14 at 18:53 -0400, Paul Moore wrote:
> On Tue, Apr 12, 2016 at 4:52 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > Will be ok if we post a v2 version of this series, removing the hooks
> > de-registration bits, but preserving the selinux nf-hooks and
> > socket_sock_rcv_skb() on-demand/delayed registration ? Will that fit
> > with the post-init read only memory usage that you are planning ?
> 
> The work Florian and and I were talking about would be limited just to
> the netfilter hooks, the LSM hooks, e.g. socket_sock_rcv_skb() and
> friends, would remain as they are today.  What what we discussing was
> defaulting to not registering the netfilter hooks until it became
> necessary due to a labeled networking configuration or the
> always_check_network policy capability; the registration of the
> netfilter hooks would be permanent, you could not unregister the hooks
> at that point, you would need to reboot.  Does that make sense?

Yes, AFAIC it makes sense. I'll try to follow this route for an eventual
v2.

> As far as Casey's concerns, I don't think the work we are talking
> about for the v2 patchset would have any effect on the socket/sock
> security blobs as you really can't manage those adequately from the
> netfilter hooks; you most likely will reference them and perhaps even
> update the data within, but not allocate or free the blobs.  Besides,
> even in some weird case you were alloc/free'ing security blobs in the
> netfilter hooks, we can deal with that on a per-LSM basis if/when the
> full fledged stacking patches are merged; everything we are talking
> about is a hidden implementation detail so changing it in the future
> shouldn't be a problem.

Casey, are you ok with the above?

Thank you,

Paolo


