From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 14:21:16 +0800
Message-ID: <20170821062116.GA73069@cran64.bj.intel.com>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818190947.GA1479@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Eric Garver <e@erig.me>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170818190947.GA1479@dev-rhel7>
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

On Sat, Aug 19, 2017 at 03:09:47AM +0800, Eric Garver wrote:
> On Fri, Aug 18, 2017 at 03:24:31PM +0800, Yi Yang wrote:
> > v3->v4
> >  - Add new NSH match field ttl
> >  - Update NSH header to the latest format
> >    which will be final format and won't change
> >    per its author's confirmation.
> >  - Fix comments for v3.
> 
> Hi Yi,
> Only a few comments below since Jiri already supplied lots of feedback.
>

Eric, thank you for your comments, I have fixed them in v5, please help
review v5, thanks a lot.
 
> > @@ -1210,6 +1373,20 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> >  		case OVS_ACTION_ATTR_POP_ETH:
> >  			err = pop_eth(skb, key);
> >  			break;
> > +
> > +		case OVS_ACTION_ATTR_PUSH_NSH: {
> > +			u8 buffer[256];
> 
> Use NSH_M_TYPE2_MAX_LEN

Replaced 256 to NSH_M_TYPE2_MAX_LEN in v5.

> > +		case OVS_NSH_KEY_ATTR_MD1: {
> > +			const struct ovs_nsh_key_md1 *md1 =
> > +				(struct ovs_nsh_key_md1 *)nla_data(a);
> > +
> > +			has_md1 = true;
> > +			memcpy(nsh->context, md1->context, sizeof(*md1));
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD2:
> > +			/* Not supported yet */
> 
> return -ENOTPSUPP if it's not supported.

Did that way in v5.

> > +		case OVS_NSH_KEY_ATTR_MD1: {
> > +			const struct ovs_nsh_key_md1 *md1 =
> > +				(struct ovs_nsh_key_md1 *)nla_data(a);
> > +
> > +			has_md1 = true;
> > +			for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++)
> > +				SW_FLOW_KEY_PUT(match, nsh.context[i],
> > +						md1->context[i], is_mask);
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD2:
> > +			/* Not supported yet */
> 
> return -ENOTPSUPP if it's not supported.

Done in v5.

> > @@ -2636,6 +2984,17 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
> >  			mac_proto = MAC_PROTO_ETHERNET;
> >  			break;
> >  
> > +		case OVS_ACTION_ATTR_PUSH_NSH:
> 
> You need to some validation here, especially the metadata lengths.
> Relying on action_lens is not enough because it's variable.
> 

Good point, I added validate_nsh for this.
