From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 10:19:24 +0200
Message-ID: <20170821101925.3f9b36a1@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
	<20170821061109.GA72656@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170821061109.GA72656-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2017 14:11:10 +0800, Yang, Yi wrote:
> In OVS code, it has been removed because of Microsoft compiler issue.

We absolutely, completely and utterly do not care in the kernel. Please
never make such arguments and never make the code look worse because of
a compiler for other operating systems.

> > I was wondering about this during the reviews of the previous versions.
> > Now I've given this more thought but I still don't see it - why is the
> > inner_protocol set here?
> 
> I saw push_mpls has it, so also set it.

MPLS supports GSO and needs this for segmentation. I don't see anything
GSO related in this patch.

How do you plan to address GSO, anyway?

> > > +	err = check_header(skb, length);
> > > +	if (unlikely(err))
> > > +		return err;
> > > +
> > > +	key->nsh.flags = nsh_get_flags(nsh);
> > 
> > Again, need to reload nsh.
> 
> I used skb->len in v5, so we can't avoid such issue.

And how do you ensure that the skb has enough headroom, then? That is
wrong. All I said is that you have to reload the pointers to the header
which is what you have to do.

> > Wouldn't it be nicer if the fields of struct ovs_nsh_key_base and of
> > struct nsh_hdr had the same names?
> 
> Such change also will impact on OVS code, so I prefer not to change
> them.

We do not care.

The order in which you send patches to different projects is your
choice. The only standard by which we measure and evaluate kernel
patches is the technical suitability of the patches. Whether or not
some other projects have dependencies on some kind of previous versions
of out of tree kernel patches have zero relevance here.

If you designed other code to depend on your notion on how a kernel API
will look like before getting the actual patches accepted to the
kernel, that's your problem and you'll have to deal with that.

> For struct nsh_hdr, we need more self-descriptive fields, but for struct
> ovs_nsh_key_base, because we need to use keys in OVS OpenFlow, so np is
> obviously better than next_proto, we also try our best to make sure the
> old NSH implementation has same match fields as the new one does.

Not relevant.

 Jiri
