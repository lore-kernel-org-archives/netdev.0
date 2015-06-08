From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 resend] Fix changing tunnel remote and local
 address to any
Date: Mon, 08 Jun 2015 10:51:51 +0200
Message-ID: <557557A7.5010004@6wind.com>
References: <20150604120117.GB7119@indiana.gru.redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34005 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbbFHIvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 04:51:54 -0400
Received: by wibut5 with SMTP id ut5so78289458wib.1
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 01:51:53 -0700 (PDT)
In-Reply-To: <20150604120117.GB7119@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/06/2015 14:01, Thadeu Lima de Souza Cascardo a =E9crit :
> If a tunnel is created with a local address, you can't change it to a=
ny.
>
>   # ip tunnel add tunl1 mode ipip remote 10.16.42.37 local 10.16.42.2=
14 ttl 64
>   # ip tunnel show tunl1
>   tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64
>   # ip tunnel change tunl1 local any
>   # echo $?
>   0
>   # ip tunnel show tunl1
>   tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64
>
> It happens that parse_args zeroes ip_tunnel_parm, and when creating t=
he
> tunnel, it is OK to leave it as is if the address is any. However, wh=
en
> changing the tunnel, the current parameters will be read from
> ip_tunnel_parm, and local and remote address won't be zeroes anymore,=
 so
> it needs to be explicitly set to any.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
