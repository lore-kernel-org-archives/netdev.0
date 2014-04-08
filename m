From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [RFC] netfilter: ct: flush net_gre->keymap_list only in
 nf_conntrack_proto_gre
Date: Tue, 8 Apr 2014 09:27:38 +0200
Message-ID: <20140408072738.GA3613@localhost>
References: <1396275258-19015-1-git-send-email-avagin@openvz.org>
 <20140407145158.GA25974@localhost>
 <20140408065600.GA15309@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org, vvs@parallels.com,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140408065600.GA15309@paralelels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 08, 2014 at 10:56:00AM +0400, Andrew Vagin wrote:
> On Mon, Apr 07, 2014 at 04:51:58PM +0200, Pablo Neira Ayuso wrote:
> > On Mon, Mar 31, 2014 at 06:14:18PM +0400, Andrey Vagin wrote:
> > > nf_ct_gre_keymap_flush() removes a nf_ct_gre_keymap object from
> > > net_gre->keymap_list and frees the object. But it doesn't clean
> > > a reference on this object from ct_pptp_info->keymap[dir].
> > > Then nf_ct_gre_keymap_destroy() may release the same object again.
> > > 
> > > So nf_ct_gre_keymap_flush() can be called only when we are sure that
> > > when nf_ct_gre_keymap_destroy will not be called.
> > > 
> > > nf_ct_gre_keymap is created by nf_ct_gre_keymap_add() and the right way
> > > to destroy it is to call nf_ct_gre_keymap_destroy().
> > 
> > I think you use call nf_ct_iterate_cleanup() to get rid of all GRE
> > conntrack entries that have a ct->master, which means that they were
> > created by PPTP. That implicitly calls gre_destroy, which releases the
> > keymap object.
> 
> I'm not sure that I understand your comment. Currently I change nothing
> about nf_ct_iterate_cleanup(). In this sentence I point to the right
> procedure of destroying a gre conntrack.
> 
> nf_ct_iterate_cleanup() is called from nf_ct_l4proto_pernet_unregister().

I was considering the scenario in which we only remove the pptp
module, so my proposal was to get rid of the gre entry that were
created through the pptp helper as well.  But we don't seem to do that
in any of our helpers and I think that cleanup is not possible in all
cases.

I'll take your patch, thanks.
