From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 19:33:14 +0100
Message-ID: <50D5FCEA.9060406@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <20121222101521.08c783ac@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:43038 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab2LVSdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 13:33:18 -0500
Received: by mail-bk0-f49.google.com with SMTP id jm19so2932793bkc.36
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2012 10:33:16 -0800 (PST)
In-Reply-To: <20121222101521.08c783ac@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> You could add another case to include/net/ndisc.h::ndisc_addr_option_pad()
> with a hardcoded size, couldn't you?
>
No, I think that is almost certainly not a good idea. The address space 
option is handed over to the firewire_net driver like this:
type, length, soure/target link address (GUID)

If I add another case in ndisc_addr_option_pad() I think the option will 
look like this:
pad, type, length, soure/target link address (GUID)

Because pad, type and GUID are already at the correct position for the 
3146 link layer option. So with padding I have to copy them to the 
correct position.

All I need is some (8 bytes) of additional tail room in the ndisc skb. 
This could be achieved either by specifying needed_tailroom in the 
firewire netdevice struct at the expense that now every skb allocated 
might get 8 bytes more allocated.

The second option is yoshfuji suggestion to pimp ndisc_opt_addr_space a 
bit. His solution only allocates additional memory for ndisc packets at 
the expense to introduce a dependency to the struct 
ndisc_opt_ieee1394_llinfo.

These are the two option we can go for. Personally I think reserving a 
bit more tail room looks cleaner if nobody votes against it...

Regards,

Stephan
