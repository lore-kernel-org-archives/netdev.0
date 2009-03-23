From: Patrick McHardy <kaber@trash.net>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 18:49:15 +0100
Message-ID: <49C7CB9B.1040409@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44958 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758501AbZCWRtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 13:49:20 -0400
In-Reply-To: <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:29:33:
>
>   
>>> There is no /proc/net/netfilter/nf_conntrack. There is a
>>> /proc/net/nf_conntrack though and it is empty. If I telnet
>>> to the board I see:
>>>       
>> That means that something is leaking conntrack references, most likely
>> by leaking skbs. Since I haven't seen any other reports, my guess would
>> be the ucc_geth driver.
>>     
>
> Mucking around with the ucc_geth driver I found that if I:
>  - Move TX from IRQ to NAPI context
>  - double the weight.
>  - after booting up, wait a few mins until the JFFS2 GC kernel thread has 
> stopped
>    scanning the FS 
>
> Then the "nf_conntrack: table full, dropping packet." msgs stops.
> Does this seem right to you guys?

No. As I said, something seems to be leaking packets. You should be
able to confirm that by checking the sk_buff slabs in /proc/slabinfo.
If that *doesn't* show any signs of a leak, please run "conntrack -E"
to capture the conntrack events before the "table full" message
appears and post the output.


