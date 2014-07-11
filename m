From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only
 require the I bit to be set
Date: Fri, 11 Jul 2014 12:41:26 -0700
Message-ID: <20140711124126.262c2876@samsung-9>
References: <cover.1405097440.git.tgraf@suug.ch>
	<cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	nicolas.dichtel@6wind.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, ogerlitz@mellanox.com,
	dborkman@redhat.com,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33834 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbaGKTl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 15:41:57 -0400
Received: by mail-wi0-f171.google.com with SMTP id f8so208978wiw.4
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 12:41:52 -0700 (PDT)
In-Reply-To: <cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2014 18:59:49 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> @@ -1617,7 +1646,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>  	}
>  
>  	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -	vxh->vx_flags = htonl(VXLAN_FLAGS);
> +	vxlan_flags(vxh) = VXLAN_FLAG_VNI;
> +	vxh->vx_reserved1 = 0;
> +	vxh->vx_reserved2 = 0;
>  	vxh->vx_vni = vni;
>  
 
Okay, but initializing bitfields generates crappy code.
Can we just alias and do one assignment.
