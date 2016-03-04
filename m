From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] vxlan: fix missing options_len update on RX with
 collect metadata
Date: Thu, 3 Mar 2016 16:16:16 -0800
Message-ID: <CAM_iQpWOUw6im=1HAemYYahY_Q3W6kW42pYQEHWRxmha1GHyHg@mail.gmail.com>
References: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
	<CAM_iQpWurWR6c2tvi1fGmNvt-6J=mE05CeKKJkLAEob3stLtZg@mail.gmail.com>
	<56D7FC98.6020505@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>, jesse@kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35385 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbcCDAQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:16:17 -0500
Received: by mail-yk0-f170.google.com with SMTP id v186so16652245yke.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 16:16:16 -0800 (PST)
In-Reply-To: <56D7FC98.6020505@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 12:58 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 03/03/2016 02:21 AM, Cong Wang wrote:
>>
>> Why not set it in tun_rx_dst() where it is allocated?
>
>
> Nope, current convention is to only fill options_len when an actual
> option was detected on RX, f.e. see ip_tunnel_info_opts_set() in
> geneve. Consumers like ovs_flow_key_extract() check for options_len
> and not TUNNEL_OPTIONS_PRESENT to copy it via ip_tunnel_info_opts_get()
> from there.

But the APIs suck...

You expect to use ip_tunnel_info_opts_{get,set}() to read or write
the tun_info, but actually this is not the case here for vxlan.

Also, ip_tunnel_info_opts_set() could write out of range if the len is
bigger than the allocated length. I know existing callers are fine, but this API
is problematic.

I think this is why we had this bug.
