From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] packet: Deliver VLAN TPID to userspace
Date: Fri, 18 Oct 2013 10:56:55 -0700
Message-ID: <20131018105655.2cdc628e@nehalam.linuxnetplumber.net>
References: <87a9i6jymc.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42256 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042Ab3JRR5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:57:01 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so5088880pdj.1
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 10:57:01 -0700 (PDT)
In-Reply-To: <87a9i6jymc.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Oct 2013 02:08:11 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index dbf0666..6e36e0a 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -83,7 +83,7 @@ struct tpacket_auxdata {
>  	__u16		tp_mac;
>  	__u16		tp_net;
>  	__u16		tp_vlan_tci;
> -	__u16		tp_padding;
> +	__u16		tp_vlan_tpid;
>  };
>  
>  /* Rx ring - header status */
> @@ -132,12 +132,13 @@ struct tpacket2_hdr {
>  	__u32		tp_sec;
>  	__u32		tp_nsec;
>  	__u16		tp_vlan_tci;
> -	__u16		tp_padding;
> +	__u16		tp_vlan_tpid;
>  };
>  
>  struct tpacket_hdr_variant1 {
>  	__u32	tp_rxhash;
>  	__u32	tp_vlan_tci;
> +	__u32	tp_vlan_tpid;
>  };

The last change will break ABI to userspace applications.
You can reuse padding elements; but you can't increase (or shrink)
an existing structure.
