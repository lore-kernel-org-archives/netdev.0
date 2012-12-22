From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 07:10:33 +0100
Message-ID: <50D54ED9.6090908@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:43964 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab2LVGKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 01:10:37 -0500
Received: by mail-bk0-f44.google.com with SMTP id w11so2713862bku.17
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 22:10:36 -0800 (PST)
In-Reply-To: <50D4BD2F.7060006@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Something like this:
>
>   static inline int ndisc_opt_addr_space(struct net_device *dev)
>   {
> -       return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> +       switch (dev->type) {
> +       case ARPHRD_IEEE1394:
> +               return sizeof(struct ndisc_opt_ieee1394_llinfo);
> +       default:
> +               return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> +       }
>   }
>
> --yoshfuji
>

O.k., this has the advantage that only ndisc packets get some more 
memory, but the question is if we are under such a hard memory pressure 
that we don't allow that.

Your solution has the disadvantage that now I have to publish struct 
ndisc_opt_ieee1394_llinfo to the ndisc stuff. Nobody in ndisc.c really 
wants to deal with that structure, only the size is of interest. So 
keeping this struct private is less invasive to the rest of linux. Just 
my two cents.

Regards,

Stephan
