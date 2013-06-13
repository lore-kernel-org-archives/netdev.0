From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/4] openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()
Date: Wed, 12 Jun 2013 19:52:03 -0700
Message-ID: <CAEP_g=9wNpx4P1anDo1v0996z1=VqJrMkNQsb87CGfHfNxb9FA@mail.gmail.com>
References: <1371077824-19718-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:45662 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932071Ab3FMCwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 22:52:24 -0400
Received: by mail-ie0-f175.google.com with SMTP id a13so12315181iee.34
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 19:52:23 -0700 (PDT)
In-Reply-To: <1371077824-19718-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 3:57 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index b15321a..150f181 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -1122,10 +1122,9 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
>
>  /**
>   * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
> - * @priority: receives the skb priority
> - * @mark: receives the skb mark
> - * @in_port: receives the extracted input port.
> - * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
> + * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
> + * @key_len: Length of key in @flow.  Used for calculating flow hash.
> + * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
>   * sequence.
>   *
>   * This parses a series of Netlink attributes that form a flow key, which must
> @@ -1133,15 +1132,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
>   * get the metadata, that is, the parts of the flow key that cannot be
>   * extracted from the packet itself.
>   */
> -int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
> -                              const struct nlattr *attr)
> +int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
> +                                  const struct nlattr *attr)

It looks like key_len isn't actually used in this function. Is there
another piece that you meant to include?
