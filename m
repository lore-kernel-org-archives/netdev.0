From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/14] Big kfree NULL check cleanup - net
Date: Fri, 14 Oct 2005 21:51:13 +0900 (JST)
Message-ID: <20051014.215113.26967183.yoshfuji@linux-ipv6.org>
References: <200510132125.44470.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, acme@conectiva.com.br, ralf@linux-mips.org,
	greg@kroah.com, dccp@vger.kernel.org, patrick@tykepenguin.com,
	jt@hpl.hp.com, sri@us.ibm.com, andros@umich.edu, bfields@umich.edu,
	ncorbic@sangoma.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750739AbVJNMvT@vger.kernel.org>
To: jesper.juhl@gmail.com, davem@davemloft.net
In-Reply-To: <200510132125.44470.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200510132125.44470.jesper.juhl@gmail.com> (at Thu, 13 Oct 2005 21:25:43 +0200), Jesper Juhl <jesper.juhl@gmail.com> says:

> --- linux-2.6.14-rc4-orig/net/ipv4/netfilter/ip_nat_snmp_basic.c	2005-10-11 22:41:33.000000000 +0200
> +++ linux-2.6.14-rc4/net/ipv4/netfilter/ip_nat_snmp_basic.c	2005-10-13 11:31:09.000000000 +0200
> @@ -1161,8 +1161,7 @@ static int snmp_parse_mangle(unsigned ch
>  		
>  		if (!snmp_object_decode(&ctx, obj)) {
>  			if (*obj) {
> -				if ((*obj)->id)
> -					kfree((*obj)->id);
> +				kfree((*obj)->id);
>  				kfree(*obj);
>  			}	
>  			kfree(obj);

Maybe:
    if (*obj)
        kfree((*obj)->id);
    kfree(obj);

Otherwise;
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
