From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 13:51:45 +0800
Message-ID: <20170905055144.GA88800@cran64.bj.intel.com>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
	<20170904124216.6db68e8c@griffin>
	<20170904120907.GA75461@cran64.bj.intel.com>
	<20170904145744.4d8b7fd5@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170904145744.4d8b7fd5@griffin>
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

On Mon, Sep 04, 2017 at 08:57:44PM +0800, Jiri Benc wrote:
> On Mon, 4 Sep 2017 20:09:07 +0800, Yang, Yi wrote:
> > So we must do many changes if we want to break this assumption.
> 
> We may do as many changes as we want to. This is uAPI we're talking
> about and we need to get it right since the beginning. Sure, it may
> mean that some user space programs need some changes in order to make
> use of the new features. That happens every day.
> 
> I also don't understand where's the problem. It's very easy to check
> for NLA_F_NESTED and generically act based on that in the function you
> quoted. Just call a different function than format_odp_key_attr to
> handle ovs_nsh_key_attr attributes in case the nested flag is set and
> the attribute is OVS_KEY_ATTR_NSH and you're done. You'll need such
> function anyway, it's not much different code size wise to call it from
> format_odp_key_attr or from format_odp_action.

But if we follow your way, how does nla_for_each_nested handle such
pattern?

attribute1
attribute1_mask
attribute2
attribute2_mask
attribute3
attribute3_mask

I don't think this can increase performance and readability.

In current way, we just call nla_for_each_nested twice

one is for

attribute1
attribute2
attribute3

another is for

attribute1_mask
attribute2_mask
attribute3_mask

if we use one function to handle both attributes and masks, I can't
see any substantial difference between two ways as far as the
performance is concerned.

So my proposal is we needn't introduce special handling case for
OVS_KEY_ATTR_NSH in OVS_ACTION_ATTR_SET_MASKED, that will open Pandora's
box.

If we consider OVS_KEY_ATTR_NSH as a big attribute, current way is
precisely following current design pattern

attribute
mask

> 
>  Jiri
