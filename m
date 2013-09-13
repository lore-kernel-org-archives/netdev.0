From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.39 6/7] datapath: Break out deacceleration portion of vlan_push
Date: Fri, 13 Sep 2013 15:07:12 -0700
Message-ID: <CAEP_g=_ZQ6hNpxoHm6t3N=PxA+3WTrvNegL514j0R3GDM5C92A@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au> <1378711207-29890-7-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:57183 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754990Ab3IMWHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 18:07:33 -0400
Received: by mail-ie0-f180.google.com with SMTP id u16so3645616iet.25
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 15:07:32 -0700 (PDT)
In-Reply-To: <1378711207-29890-7-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 30ea1d2..6741d81 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> @@ -105,22 +105,29 @@ static int pop_vlan(struct sk_buff *skb)
>         return 0;
>  }
>
> -static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
> +/* push down current VLAN tag */
> +static struct sk_buff *put_vlan(struct sk_buff *skb)

This never changes the skb, right? Can we simplify things and just
return an error code?
