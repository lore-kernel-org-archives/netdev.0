From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Fri, 26 Oct 2012 00:42:28 +0200
Message-ID: <1351204948.6537.263.camel@edumazet-glaptop>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43875 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab2JYWmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:42:33 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1685022wgb.1
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 15:42:32 -0700 (PDT)
In-Reply-To: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 15:27 -0700, Vincent Li wrote:
> Hi,
> 
> this sounds crazy, we have a weird situation that an unknown tcp
> implementation not putting tcp MSS option in the SYN/ACK which caused
> us some issue. I am tasked to mimic the unknown tcp immplementation on
> not sending MSS in tcp SYN/ACK, I am wondering if I can achieve that
> by modifying linux kernel tcp code,  there is socket option
> TCP_MAXSEG, but that seems only affecting the size of MSS, not
> removing the MSS option. do you have any pointer on how to do that in
> kernel tcp code?

You'll have to patch the code.

Or else, you could add a new feature to net/netfilter/xt_TCPMSS.c

(We already have 

#define XT_TCPMSS_CLAMP_PMTU 0xffff

You could add

#define XT_TCPMSS_REMOVE 0xfffe

and replace MSS option by NOP
