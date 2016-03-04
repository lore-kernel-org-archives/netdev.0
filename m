From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] vxlan: fix missing options_len update on RX with
 collect metadata
Date: Fri, 04 Mar 2016 03:22:54 +0100
Message-ID: <56D8F17E.1020607@iogearbox.net>
References: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>	<CAM_iQpWurWR6c2tvi1fGmNvt-6J=mE05CeKKJkLAEob3stLtZg@mail.gmail.com>	<56D7FC98.6020505@iogearbox.net> <CAM_iQpWOUw6im=1HAemYYahY_Q3W6kW42pYQEHWRxmha1GHyHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>, jesse@kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34295 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbcCDCXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 21:23:01 -0500
In-Reply-To: <CAM_iQpWOUw6im=1HAemYYahY_Q3W6kW42pYQEHWRxmha1GHyHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2016 01:16 AM, Cong Wang wrote:
> On Thu, Mar 3, 2016 at 12:58 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 03/03/2016 02:21 AM, Cong Wang wrote:
>>>
>>> Why not set it in tun_rx_dst() where it is allocated?
>>
>> Nope, current convention is to only fill options_len when an actual
>> option was detected on RX, f.e. see ip_tunnel_info_opts_set() in
>> geneve. Consumers like ovs_flow_key_extract() check for options_len
>> and not TUNNEL_OPTIONS_PRESENT to copy it via ip_tunnel_info_opts_get()
>> from there.
>
> But the APIs suck...
>
> You expect to use ip_tunnel_info_opts_{get,set}() to read or write
> the tun_info, but actually this is not the case here for vxlan.

Yep, since depending on the working mode either skb->mark is populated
or the tunnel opts buffer.

> Also, ip_tunnel_info_opts_set() could write out of range if the len is
> bigger than the allocated length. I know existing callers are fine, but this API
> is problematic.

Current call sites are good agree, API could probably be better, yeah.

> I think this is why we had this bug.
