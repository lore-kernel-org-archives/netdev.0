From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 65271] New: Acceptable RST packets (with seq number in
 window) are ignored in LAST_ACK state (and previously sent data pending
 acknowledgement)
Date: Wed, 20 Nov 2013 12:41:12 -0800
Message-ID: <1384980072.10637.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131120122211.386c9680@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	julien.delacroix@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:43652 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab3KTUlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:41:14 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so10377908pbc.26
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:41:13 -0800 (PST)
In-Reply-To: <20131120122211.386c9680@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 12:22 -0800, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Wed, 20 Nov 2013 07:03:59 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 65271] New: Acceptable RST packets (with seq number in window) are ignored in LAST_ACK state (and previously sent data pending acknowledgement)
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=65271
> 
>             Bug ID: 65271
>            Summary: Acceptable RST packets (with seq number in window) are
>                     ignored in LAST_ACK state (and previously sent data
>                     pending acknowledgement)
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.59-0.7-default
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: julien.delacroix@gmail.com
>         Regression: No
> 
> Created attachment 115271
>   --> https://bugzilla.kernel.org/attachment.cgi?id=115271&action=edit
> TCP dump showing described scenario
> 
> PCAP file of traffic capture is attached.
> Note that capture was taken directly on server host, so RST packets definitely
> reached the server host.
> 
> 
> Here is the flow:
> 
> 1: Client ---- SYN ----> Server
> 2: Client <- SYN, ACK -- Server
> 3: Client ---- ACK ----> Server 
> 4: Client ---- FIN ----> Server ( server in CLOSE_WAIT state)
> 5: Client <- PSH, ACK -- Server 
> 6: Client <- FIN, ACK -- Server ( server in LAST_ACK state)
> 
> 7: Client ---- RST ----> Server 
> 
> Then repeat N times:
>     8: Client <- PSH, ACK -- Server 
>     9: Client ---RST, ACK -> Server 
> 
> 
> Notes:
> 5: packet contains 3 bytes of data
> 7: no ACK flag, and sequence number is correct, but RST packet is ignored
> 8: retransmission of step 5
> 9: the sequence number is correct as well as the acknowledgment number
> (acknowledging data in 5, but not yet FIN in 6), but this RST is again ignored.
> 
> From this point client keeps retransmitting 5, while server keeps answering
> with acceptable RST packets.
> 
> You can observe this scenario (with 5 retransmissions and 5 RST) in the
> attached PCAP file.
> 

Thanks for the report, you'll take a look.
