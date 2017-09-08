From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Fri, 8 Sep 2017 14:13:23 +0800
Message-ID: <20170908061322.GA15698@cran64.bj.intel.com>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170831124516.0c5db686@griffin>
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

On Thu, Aug 31, 2017 at 06:45:16PM +0800, Jiri Benc wrote:
> On Wed, 30 Aug 2017 20:39:12 +0800, Yi Yang wrote:
> > +			nsh->md1.context[i] =
> > +			    OVS_MASKED(nsh->md1.context[i], key->context[i],
> > +				       mask->context[i]);
> > +		}
> > +		memcpy(flow_key->nsh.context, nsh->md1.context,
> > +		       sizeof(nsh->md1.context));
> 
> Do you follow the discussion that Hannes Sowa started on the ovs list
> regarding matching on the context fields? It would be better to hold on this
> until there's a conclusion reached.

We had several back-and-forth discussions, Jan was also involved, the
conslusion is current way is still the best way we can have, we need
set and match for context fields.

> > +			    type,
> > +			    nla_len(a),
> > +			    ovs_nsh_key_attr_lens[type].len
> > +			);
> > +			return -EINVAL;
> > +		}
> 
> These checks should be done only once when the action is configured, not for
> each packet.

in v8, nsh_key_put_from_nlattr is only one check point, validate_nsh calls it
for set and push_nsh, nsh_hdr_from_nlattr and nsh_key_from_nlattr
haven't these checked anymore because validate_nsh has done them.

> > +	if (unlikely(!has_md1 && !has_md2)) {
> > +		OVS_NLERR(1, "neither nsh md1 nor md2 attribute is there");
> > +		return -EINVAL;
> > +	}
> 
> Ditto. Plus I don't see a check that the OVS_NSH_KEY_ATTR_BASE attribute is
> present. Seems that the compiler warned you about possibly unitialized flags
> and ttl variables and you just silenced the warning without considering
> whether it's not actually justified.

nsh_key_put_from_nlattr is used for both set and push_nsh, so
OVS_NSH_KEY_ATTR_BASE check is valid only for push_nsh, it is possible
for set not to have OVS_NSH_KEY_ATTR_BASE. v8 has been successfully built
without any warnings, it is also verified in sfc test environment.

I think v8 has fixed all the comments for v7, I have sent out v8 to
mailing list, please help review it, thanks a lot.
