From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Fri, 26 Oct 2012 15:54:17 -0700
Message-ID: <CAK3+h2y0M5kytB2q+S0aX+FsVw08VQciSH+aLVM6JTmvVwydgQ@mail.gmail.com>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
	<1351204948.6537.263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:61737 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934184Ab2JZWyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 18:54:17 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so4478570iea.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 15:54:17 -0700 (PDT)
In-Reply-To: <1351204948.6537.263.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 3:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-10-25 at 15:27 -0700, Vincent Li wrote:
>> Hi,
>>
>> this sounds crazy, we have a weird situation that an unknown tcp
>> implementation not putting tcp MSS option in the SYN/ACK which caused
>> us some issue. I am tasked to mimic the unknown tcp immplementation on
>> not sending MSS in tcp SYN/ACK, I am wondering if I can achieve that
>> by modifying linux kernel tcp code,  there is socket option
>> TCP_MAXSEG, but that seems only affecting the size of MSS, not
>> removing the MSS option. do you have any pointer on how to do that in
>> kernel tcp code?
>
> You'll have to patch the code.
>
> Or else, you could add a new feature to net/netfilter/xt_TCPMSS.c
>
> (We already have
>
> #define XT_TCPMSS_CLAMP_PMTU 0xffff
>
> You could add
>
> #define XT_TCPMSS_REMOVE 0xfffe
>
> and replace MSS option by NOP
>
>
>

for the sake of complete information, net/netfilter/xt_TCPOPTSTRIP.c
already have this feature to strip tcp option

Vincent
