From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 09/12] openvswitch: Add tunneling interface.
Date: Fri, 14 Jun 2013 17:23:29 -0700
Message-ID: <CAEP_g=_rcJtfDYxt9cENZDHaiv9D0pRbobsr7Aw9sHNeM6BMkw@mail.gmail.com>
References: <1371147899-9442-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:41638 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752232Ab3FOAXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 20:23:50 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar20so2638195iec.7
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 17:23:49 -0700 (PDT)
In-Reply-To: <1371147899-9442-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:24 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index fba57a0..575c0bd 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
>  static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
> @@ -938,14 +942,14 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
>                 u16 type = nla_type(nla);
>                 int expected_len;
>
> -               if (type > OVS_KEY_ATTR_MAX || attrs & (1 << type))
> +               if (type > OVS_KEY_ATTR_MAX || attrs & (1ULL << type))

The use of 1ULL (64-bit flags) is from the old compatibility code so
it's not needed anymore.

> +int ipv4_tun_from_nlattr(const struct nlattr *attr,
> +                        struct ovs_key_ipv4_tunnel *tun_key)

We should prefix these function names with ovs_.
