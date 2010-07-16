From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
	mapping
Date: Fri, 16 Jul 2010 16:02:23 -0400
Message-ID: <AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com>
References: <AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
	<20100716.123306.232886890.davem@davemloft.net>
	<AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
	<20100716.124031.220080717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48324 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759188Ab0GPUCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:02:24 -0400
Received: by vws5 with SMTP id 5so2940985vws.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 13:02:23 -0700 (PDT)
In-Reply-To: <20100716.124031.220080717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 3:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Chetan Loke <chetanloke@gmail.com>
> Date: Fri, 16 Jul 2010 15:35:48 -0400
>
>> Yes, I opened a socket and then sent the IFCONF ioctl.What I meant was
>> that interfaces that didn't have an IP weren't returned.
>
> If you use the correct set of ioctl()'s it will, just as
> "/sbin/ifconfig -a" lists all interfaces regardless of whether they
> have IP addresses.
>
> Run strace on 'ifconfig', see what it does :-)

I grep the /sys nodes in my existing code already ;) and I didn't want
to do that.If we plop the single for-each-netdev loop then wouldn't it
be easier?

>
> And then you also have the option of using netlink as well.
> This is how "ip l l" lists all interfaces, also regardless of
> configuration.
>

So all user space apps should replicate code when all of that can be
replaced at the cost of a single for-loop in a non fast-path code
within the kernel?
