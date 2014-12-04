From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 10:15:04 -0600
Message-ID: <87y4qne6if.fsf@x220.int.ebiederm.org>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.c
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43629 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbaLDQRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 11:17:23 -0500
In-Reply-To: <1417683438-10935-2-git-send-email-jiri@resnulli.us> (Jiri
	Pirko's message of "Thu, 4 Dec 2014 09:57:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

Would someone please explain to me what a switch id is?

I looked in the kernel source, and I looked here and while I know
switches I don't have a clue what a switch id is.

My primary concern at this point is that you have introduced a global
identifier that is isn't a hardware property (it certainly does not look
like a mac address) and that is unique across network namespaces and
thus breaks checkpoint/restart (aka CRIU).

Also what in the world does PHYS mean in IFLA_PHYS_SWITCH_ID?  Does that
mean we can't have a purely software implementation of this interface?
Given that we will want a software implementation at some point
including PHYS in the name seems completely wrong.

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/if_link.h | 1 +
>  ip/ipaddress.c          | 8 ++++++++
>  2 files changed, 9 insertions(+)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 4732063..a6e2594 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -145,6 +145,7 @@ enum {
>  	IFLA_CARRIER,
>  	IFLA_PHYS_PORT_ID,
>  	IFLA_CARRIER_CHANGES,
> +	IFLA_PHYS_SWITCH_ID,
>  	__IFLA_MAX
>  };
>  
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 4d99324..bd36a07 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -589,6 +589,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>  				      b1, sizeof(b1)));
>  	}
>  
> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
> +		SPRINT_BUF(b1);
> +		fprintf(fp, "switchid %s ",
> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
> +				      b1, sizeof(b1)));
> +	}
> +
>  	if (tb[IFLA_OPERSTATE])
>  		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
