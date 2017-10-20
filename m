From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v12] openvswitch: enable NSH support
Date: Fri, 20 Oct 2017 19:34:40 +0800
Message-ID: <20171020113440.GA102327@cran64.bj.intel.com>
References: <1508162009-30359-1-git-send-email-yi.y.yang@intel.com>
	<20171018231955.058ec5c8@griffin>
	<20171019114052.GA83037@cran64.bj.intel.com>
	<20171019144347.421351db@griffin>
	<20171019131215.GA84551@cran64.bj.intel.com>
	<20171019154118.16d906e0@griffin>
	<20171019215312.GA91385@cran64.bj.intel.com>
	<20171020100535.152fd925@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171020100535.152fd925@griffin>
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

On Fri, Oct 20, 2017 at 04:05:35PM +0800, Jiri Benc wrote:
> On Fri, 20 Oct 2017 05:53:12 +0800, Yang, Yi wrote:
> > For push_nsh, my typical use scinario is push_nsh then set then output
> > to vxlangpe port.
> 
> Okay.

Then I just need to do the below change against v12.

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1ab3c51..a3a663c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -658,10 +658,8 @@ static int set_nsh(struct sk_buff *skb, struct
sw_flow_key *flow_key,
                return err;

        /* Make sure the NSH base header is there */
-       err = skb_ensure_writable(skb, skb_network_offset(skb) +
-                                      NSH_BASE_HDR_LEN);
-       if (unlikely(err))
-               return err;
+       if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
+               return -ENOMEM;

        nh = nsh_hdr(skb);
        length = nsh_hdr_len(nh);

I'll send out v13 with this if you're ok.

> 
>  Jiri
