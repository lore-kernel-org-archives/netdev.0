From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Mon, 27 Feb 2012 08:58:55 -0500
Message-ID: <1330351135.2384.1039.camel@mojatatu>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41063 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab2B0N7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 08:59:05 -0500
Received: by mail-iy0-f174.google.com with SMTP id z13so3288593iaz.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 05:59:05 -0800 (PST)
In-Reply-To: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anton,

On Sat, 2012-02-25 at 22:01 +0400, Anton 'EvilMan' Danilov wrote:
> This patch adds the ability to set the mask for changing bits. The
> mask parameter is optional.
> 
> Example of usage:
> #rewrite vlan id. cos field in 802.1q header is unchanged.
> ip link add link eth0 name eth0.99 type vlan id 99 reorder_hdr off
> egress-qos-map 0:7
> tc qdisc add dev eth0 root handle 1: prio bands 8
> tc filter add dev eth0 parent 1: protocol all pref 1 u32
> tc filter add dev eth0 parent 1: protocol all pref 1 handle ::1 u32 \
>    match u16 0x8100 0xffff at -6 \
>    match u16 0x0063 0x0fff at -4 \
>    classid 1:5 \
>    action pedit munge offset -4 u16 set 0x000d 0x0fff

Looks like a reasonable feature to have - but it has to continue working
as before for things that dont need the mask.

> 
> diff --git a/tc/m_pedit.c b/tc/m_pedit.c
> index 7499846..f081eff 100644
> --- a/tc/m_pedit.c
> +++ b/tc/m_pedit.c

> 
> 	tkey->val = htonl(tkey->val & retain);
> -	tkey->mask = htonl(tkey->mask | ~retain);
> +	tkey->mask = htonl(~tkey->mask | ~retain);

A change like the above worries me that this may work for your use case
but will break other things that used to work. I'd like to run some
tests but dont have the cycles for the next few days. Alternatively, I
could explain some tests to you and you could validate and fix whatever
breaks.
Let me know what is best for you.

cheers,
jamal
