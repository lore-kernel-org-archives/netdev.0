From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 15:16:01 +0200
Message-ID: <20170904151601.2f198a53@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
	<20170904124216.6db68e8c@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
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

On Mon, 4 Sep 2017 12:57:15 +0000, Jan Scheurich wrote:
> So is what you are suggesting the following?
> 
> For matching:
> OVS_KEY_ATTR_NSH_BASE_HEADER		mandatory
> OVS_KEY_ATTR_NSH_MD1_CONTEXT		optional, in case MDTYPE == MD1

This needs to be:

OVS_KEY_ATTR_NSH
	OVS_KEY_ATTR_NSH_BASE_HEADER
	OVS_KEY_ATTR_NSH_MD1_CONTEXT

> For setting:
> OVS_ACTION_ATTR_SET_MASKED
> -    OVS_KEY_ATTR_NSH_BASE_HEADER		when setting any base header fields
> OVS_ACTION_ATTR_SET_MASKED
> -    OVS_KEY_ATTR_NSH_MD1_CONTEXT	when setting any MD1 context data fields

This needs to be:

OVS_ACTION_ATTR_SET_MASKED
	OVS_KEY_ATTR_NSH
		OVS_KEY_ATTR_NSH_BASE_HEADER
		OVS_KEY_ATTR_NSH_MD1_CONTEXT

In your example, there's no way to distinguish OVS_KEY_ATTR_ENCAP and
OVS_KEY_ATTR_NSH_BASE_HEADER, they are both "1".

> Should we consider to stick to that simple and efficient approach? As far 
> As I can see it will be generic for the foreseeable future.

I'm not sure. From the kernel point of view, we want the same
functionality offered by the openvswitch module and by a tc action.

In theory, it can be the tc tool that constructs the header from the
command line but there's no precedent. Dunno.

 Jiri
