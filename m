From: Joe Stringer <joe@ovn.org>
Subject: Re: [ovs-dev] [PATCH net v2] openvswitch: fix conntrack netlink event delivery
Date: Wed, 29 Jun 2016 11:47:15 +0200
Message-ID: <CAPWQB7F+JgzPtSf=aUAmuAa77L2EE0p7qMWRe_A4xfH-wwo3wg@mail.gmail.com>
References: <CAPWQB7HUqyK8EiTZagaxV=g_3An9meNgtBAOWUh_UVDgWwuoPQ@mail.gmail.com>
 <1467127346-23743-1-git-send-email-samuel.gauthier@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	ovs dev <dev@openvswitch.org>, netdev <netdev@vger.kernel.org>,
	Joe Stringer <joestringer@nicira.com>,
	netfilter-devel@vger.kernel.org, Justin Pettit <jpettit@nicira.com>
To: Samuel Gauthier <samuel.gauthier@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467127346-23743-1-git-send-email-samuel.gauthier@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28 June 2016 at 17:22, Samuel Gauthier <samuel.gauthier@6wind.com> wrote:
> Only the first and last netlink message for a particular conntrack are
> actually sent. The first message is sent through nf_conntrack_confirm when
> the conntrack is committed. The last one is sent when the conntrack is
> destroyed on timeout. The other conntrack state change messages are not
> advertised.
>
> When the conntrack subsystem is used from netfilter, nf_conntrack_confirm
> is called for each packet, from the postrouting hook, which in turn calls
> nf_ct_deliver_cached_events to send the state change netlink messages.
>
> This commit fixes the problem by calling nf_ct_deliver_cached_events in the
> non-commit case as well.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> CC: Joe Stringer <joestringer@nicira.com>
> CC: Justin Pettit <jpettit@nicira.com>
> CC: Andy Zhou <azhou@nicira.com>
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>

Acked-by: Joe Stringer <joe@ovn.org>
