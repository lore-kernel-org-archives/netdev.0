From: Alexandre Cassen <acassen@freebox.fr>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Wed, 23 Sep 2009 08:07:33 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0909230806040.23721@lnxos.staff.proxad.net>
References: <20090922220251.GA22874@lnxos.staff.proxad.net> <4AB94D2C.4000006@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:33572 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbZIWGHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 02:07:40 -0400
In-Reply-To: <4AB94D2C.4000006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 23 Sep 2009, Eric Dumazet wrote:
>> +#ifdef CONFIG_IPV6_SIT_6RD
>> +	case SIOCGET6RD:
>> +		err = -EINVAL;
>> +		if (dev == sitn->fb_tunnel_dev)
>> +			goto done;
>> +		err = -ENOENT;
>> +		if (!(t = netdev_priv(dev)))
>> +			goto done;
>
>> +		memcpy(&ip6rd, &t->ip6rd_prefix, sizeof(ip6rd));
>
> Just wondering why you need a temporary ip6rd here,
> why dont you copy_to_user(ifr->ifr_ifru.ifru_data, &t->ip6rd_prefix, sizeof(ip6rd)); ?
>
>> +		if (copy_to_user(ifr->ifr_ifru.ifru_data, &ip6rd, sizeof(ip6rd)))
>> +			err = -EFAULT;
>> +		else
>> +			err = 0;
>> +		break;

agreed. will fix.
