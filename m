From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user
 space
Date: Fri, 31 Jul 2015 08:41:40 -0700
Message-ID: <55BB9734.1010005@plumgrid.com>
References: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
 <20150731080019.GB4738@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36335 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbbGaPll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 11:41:41 -0400
Received: by pdjr16 with SMTP id r16so45658570pdj.3
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 08:41:41 -0700 (PDT)
In-Reply-To: <20150731080019.GB4738@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/15 1:00 AM, Thomas Graf wrote:
> On 07/30/15 at 08:10pm, Alexei Starovoitov wrote:
>> Two vxlan driver flags FLOWBASED and COLLECT_METADATA need to be set to
>> make use of its new flow mode. The former already exposed. Expose the latter.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Since you are analyzing the program when you load it. Could you call
> ip_tunnel_need_metadata() when we load a program which accesses
> the new metadata field and ip_tunnel_unneed_metadata() when you unload
> it? This would hide the need to set this flag from the user. The con
> is that it enables metadata on all net_devices.

I thought about it, but the global static_key enabler via
ip_tunnel_collect_metadata() is an overkill when we only want
to enable it for one tunnel. I can imagine why you may need
it for routing, but every tunnel type needs its own
collect_metadata flag similar to vxlan.
Also in bpf there is no program scan at unload time.
To call ip_tunnel_unneed_metadata() cleanly, I would need to
extra global refcnt just for that. which is ugly.

> I'm also fine with exposing this flag to the user though. I'll leave it
> up to you so feel free to add my ack if you want to go this route.
>
> Acked-by: Thomas Graf <tgraf@suug.ch>

thanks. I think exposing collect_metadata for vxlan and in the future
for other tunnel types is the clean enough way, though the other
alternative would be to get rid of collect_metadata flag
from the kernel and do it when flowmode flag is set. Thoughts?
