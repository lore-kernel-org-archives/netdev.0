From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15683] New: XFRM IS NOT UPDATING ETH TYPE
 FIELD FOR INNER PACKET ON ETH
Date: Mon, 5 Apr 2010 12:55:13 -0700
Message-ID: <20100405125513.016ba9c4.akpm@linux-foundation.org>
References: <bug-15683-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	eduardo.panisset@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41875 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755918Ab0DET4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:56:21 -0400
In-Reply-To: <bug-15683-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend - I forgot to cc Eduardo)

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 2 Apr 2010 18:17:07 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15683
> 
>            Summary: XFRM IS NOT UPDATING ETH TYPE FIELD FOR INNER PACKET
>                     ON ETH
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.28-2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: eduardo.panisset@gmail.com
>         Regression: No
> 
> 
> Before doing this change wireshark was showing the inner packet as
> "malformed" as it uses the ethernet's type field to classify the L3
> packets as IPv6, IPv4 and so on.
> The problem is when the inner packet is reinserted into Linux stack
> and the ethernet header keeps holding on its type field a value for
> the protocol of outer packet.
> 
> Below my correction on file net/xfrm/xfrm_input.c, function xfrm_prepare_input:
> 
> ...
> 
> skb->protocol = inner_mode->afinfo->eth_proto; // existing code
> eth_hdr(skb)->h_proto = skb->protocol; // my change, adding this line
> 
> ...
> 

