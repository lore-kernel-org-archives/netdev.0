From: Lance Richardson <lrichard-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [net]openvswitch: Clear the ct flow key for the
 recirculated packet
Date: Thu, 16 Mar 2017 17:11:35 -0400 (EDT)
Message-ID: <941889157.2725572.1489698695710.JavaMail.zimbra@redhat.com>
References: <af0d1942-726b-b637-e8e3-2f4857bb00a2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <af0d1942-726b-b637-e8e3-2f4857bb00a2-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

> From: "Numan Siddique" <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "ovs dev" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
> Cc: "Joe Stringer" <joe-LZ6Gd1LRuIk@public.gmane.org>, "Andy Zhou" <azhou-LZ6Gd1LRuIk@public.gmane.org>, jarno-LZ6Gd1LRuIk@public.gmane.org
> Sent: Thursday, March 16, 2017 8:25:06 AM
> Subject: [RFC] [net]openvswitch: Clear the ct flow key for the recirculated packet
> 
> It is possible that the ct flow key information would have
> gone stale for the packets received from the userspace due to
> clone or ct_clear actions.
> 
> In the case of OVN, it adds ping responder flows, which modifies
> the original icmp4 request packet to a reply packet. It uses the
> OVS actions - clone and ct_clear. When the reply packet hits the
> "ovs_ct_execute" function, and since the ct flow key info is not
> cleared, the connection tracker doesn't set the state to
> ESTABLISHED state.
> 
> Note: This patch is marked as RFC, as I am not sure if this is the correct
> place to address this issue or it should be addressed in ovs-vswitchd
> to set the OVS_KEY_ATTR_CT_STATE and other related attributes
> properly for ct_clear action.
> 
> Signed-off-by: Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---

Hi Numan,

With this patch applied I'm consistently seeing failures for two of the
kernel datapath unit tests (via "make check-kernel"):

 16: conntrack - force commit                        FAILED (system-traffic.at:692)
 54: conntrack - SNAT with ct_mark change on reply   FAILED (system-traffic.at:2446)
