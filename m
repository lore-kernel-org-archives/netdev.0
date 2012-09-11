From: Ulrich Weber <ulrich.weber@gmail.com>
Subject: Re: IPv6 multipath routes
Date: Tue, 11 Sep 2012 14:57:41 +0200
Message-ID: <504F3545.2070103@gmail.com>
References: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36983 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab2IKM5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 08:57:45 -0400
Received: by eaac11 with SMTP id c11so248762eaa.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 05:57:44 -0700 (PDT)
In-Reply-To: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vincent,

there is no multipath support for IPv6 in the kernel.
RTA_MULTIPATH attributes are not parsed for IPv6.

Cheers
  Ulrich

On 09/06/2012 07:30 PM, Vincent Bernat wrote:
> Hi!
>
> It appears that "ip -6 route add" expects IPv4 addresses with nexthop directives:
>
> $ ip -6 route add to 2a01:c9c0:a1:982::/64 proto bird \
>     nexthop via fe80::ea39:35ff:febd:f9e dev bai2.2008 weight 1 \
>     nexthop via fe80::ea39:35ff:febd:fd6 dev bai1.2009 weight 1
> Error: an IP address is expected rather than "fe80::ea39:35ff:febd:f9e"
>
> The following patch fix this problem. However, it does not work. I now have:
>   RTNETLINK answers: No such device
>
> I have little knowledge of netlink so it is likely that my patch is
> buggy. However, I have found this problem by trying to debug what
> appears to be a valid netlink message refused by the kernel with the
> same error. Therefore, I suspect that there is also a bug in the kernel.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
