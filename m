From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: [PATCH 3/7] net: replace NIPQUAD() in net/netfilter/
Date: Mon, 3 Nov 2008 17:56:08 +0100
Message-ID: <43ca39800811030856u5acf9601s6aef81887f19f859@mail.gmail.com>
References: <1225412025.5574.34.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:29918 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbYKCQ4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 11:56:10 -0500
Received: by an-out-0708.google.com with SMTP id d40so61357and.1
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 08:56:09 -0800 (PST)
In-Reply-To: <1225412025.5574.34.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 31, 2008 at 1:13 AM, Harvey Harrison
<harvey.harrison@gmail.com> wrote:
> Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
> can be replaced with %pI4
>
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
[...]

I just noticed that this breaks IPv4 addresses in IPVS debug output
(didn't check in other places). It seems that during integer to ASCII
conversion, the converted digits are output the wrong way around (not
endianness though). For example, 10.0.0.254 is output as 01.0.0.452.
Could something be wrong with ip4_addr_string() or put_dec_trunc() in
lib/vsprintf.c?

Julius
