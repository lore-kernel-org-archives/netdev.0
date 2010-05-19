From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: dev_get_valid_name buggy with hash collision
Date: Wed, 19 May 2010 20:05:49 +0300
Message-ID: <201005192005.49459.opurdila@ixiacom.com>
References: <4BF26926.4070507@free.fr> <201005181529.37420.opurdila@ixiacom.com> <4BF2AA68.5090008@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12427 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753524Ab0ESRHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 13:07:11 -0400
In-Reply-To: <4BF2AA68.5090008@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 May 2010 17:55:36 you wrote:

> >>         if (!dev_valid_name(name))
> >>                 return -EINVAL;
> >>
> >>         if (fmt&&  strchr(name, '%'))
> >> -               return __dev_alloc_name(net, name, buf);
> >> +               return dev_alloc_name(dev, name);
> >>         else if (__dev_get_by_name(net, name))
> >>                 return -EEXIST;
> >> -       else if (buf != name)
> >> -               strlcpy(buf, name, IFNAMSIZ);
> >> +       else if (strncmp(dev->name, name, IFNAMSIZ))
> >> +                strlcpy(dev->name, name, IFNAMSIZ);
> >
> > Why do the strncmp, can't we preserve the (buf != name) condition
> 
> The 'buf' parameter is no longer passed to the function. We have the
> 'dev'  and the 'newname' parameters.
> The pointer test was just to check 'dev_get_valid_name' was called from
> the 'register_netdevice' function context with 'dev_get_valid_name(net,
> dev->name, dev->name, 0)'. Comparing the strings is valid in this case.
> 
> Otherwise dev_get_valid_name is called from:
> 
>   *  "dev_change_net_namespace" with "dev%d" or "ifname" specified
> within the netlink message. Both are different pointers, the first will
> fall in the "if (fmt && strchr(name, '%'))".
> 
>   * "dev_change_name", where the pointers are different and the strings
> are different.
> 

True, but we why not use "if (dev->name !=name)" instead of strncmp? It should 
yield the same results and it is lighter then full strncmp.

