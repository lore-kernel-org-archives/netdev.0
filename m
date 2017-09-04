From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 16:13:03 +0200
Message-ID: <20170904161303.69624386@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
	<20170904124216.6db68e8c@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
	<20170904151601.2f198a53@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4EEB@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4EEB-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
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

On Mon, 4 Sep 2017 14:07:45 +0000, Jan Scheurich wrote:
> Then perhaps I misunderstood your comment. I thought you didn't like that the 
> SET_MASKED action wrapped OVS_KEY_ATTR_NSH which in itself was nested.
> I was aiming to avoid this by lifting the two components of the NSH header 
> components to the top level:
> OVS_NSH_ATTR_BASE_HEADER --> OVS_KEY_ATTR_NSH_BASE_HEADER
> OVS_NSH_ATTR_MD1_CONTEXT --> OVS_KEY_ATTR_NSH_MD1_CONTEXT

No, this should be a nested attr.

I objected to the way value+mask combo is handled.

> See above. The two would be separate values in the same enum, i.e. distinct.

This is not how netlink attrs should be designed.

> Not sure I have the full picture here. Are you saying that the tc tool uses the same
> Netlink API to the kernel as OVS? What would be the back-end for tc? Also the
> openvswitch kernel module? 

It does not use the same API but it makes sense for these two to share
common code. Plus hw offloading in ovs is done using tc.

 Jiri
