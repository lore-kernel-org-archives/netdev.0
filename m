From: Brandon Cazander <brandon.cazander@multapplied.net>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Wed, 3 Aug 2016 15:47:36 +0000
Message-ID: <BL2PR07MB23061A24DD64E80532DBD9799E060@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160729132154.GB13634@breakpoint.cc>
 <BL2PR07MB2306B2B920C441DF5406B1439E050@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160802221121.GB31209@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0080.outbound.protection.outlook.com ([104.47.42.80]:14875
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751351AbcHCQCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 12:02:13 -0400
In-Reply-To: <20160802221121.GB31209@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think that it is worth doing, as the original kernel change broke my user space program and could do the same to others as well.

On another setup, even with the DIVERT rule in place, I'm still seeing the RST after the ACK. I'm not sure how it is behaving differently than the other setup so I need to look into that. But it definitely worked before the changes to the kernel.

From: Florian Westphal <fw@strlen.de>
Sent: Tuesday, August 2, 2016 3:11 PM
To: Brandon Cazander
Cc: Florian Westphal
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
    
Brandon Cazander <brandon.cazander@multapplied.net> wrote:
> >     Please try this patch, it makes it work for me again.
> >       I decided to extend the existing snat support in xt_socket.c instead
> >       of changing TPROXY target:
> 
> This fixes my example (with the DIVERT chain), but does not fix the two-line example you gave below. Another setup I have is also still broken as of this diff (similarly, there is a rule in nat PREROUTING that goes to a chain with the TPROXY rule).

Yes, I did not touch TPROXY target, we would need something similar
(take tuple addresses from the conntrack entry) there as well if we
need to make it work without the -m socket rule.

    
