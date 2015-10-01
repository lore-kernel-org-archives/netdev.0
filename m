From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/6] openvswitch: Pass net into ovs_fragment
Date: Thu, 1 Oct 2015 10:31:49 +0200
Message-ID: <560CEF75.9050703@6wind.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
 <1443648336-31741-2-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36776 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbbJAIbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 04:31:52 -0400
Received: by wicgb1 with SMTP id gb1so17961312wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 01:31:51 -0700 (PDT)
In-Reply-To: <1443648336-31741-2-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/09/2015 23:25, Eric W. Biederman a =C3=A9crit :
> In preparation for the ipv4 and ipv6 fragmentation code taking a net
> parameter pass a struct net into ovs_fragment where the v4 and v6
> fragmentation code is called.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
[snip]
> @@ -748,6 +748,7 @@ static void do_output(struct datapath *dp, struct=
 sk_buff *skb, int out_port,
>   		if (likely(!mru || (skb->len <=3D mru + ETH_HLEN))) {
>   			ovs_vport_send(vport, skb);
>   		} else if (mru <=3D vport->dev->mtu) {
> +			struct net *net =3D read_pnet(&dp->net);
nit: add an empty line after variables declaration.

>   			__be16 ethertype =3D key->eth.type;
>
>   			if (!is_flow_key_valid(key)) {
[snip]
