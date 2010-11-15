From: Kevin Cernekee <cernekee@gmail.com>
Subject: Re: [PATCH/RFC] netfilter: nf_conntrack_sip: Handle quirky Cisco phones
Date: Sun, 14 Nov 2010 19:01:17 -0800
Message-ID: <AANLkTi==8nwn3g5t1uw=CP1K0vegUE2hAdDxOq-fkVRW@mail.gmail.com>
References: <28d666269c390965f1a4edca42f93c12@localhost>
	<1289725175.2743.65.camel@edumazet-laptop>
	<AANLkTik4PLga8mX73c8iONPeOtpDiuDhfu3xiPmF07jC@mail.gmail.com>
	<1289764664.2743.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289764664.2743.110.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 14, 2010 at 11:57 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Via: SIP/2.0/UDP 192.168.2.28:5060;branch=xxxxxxxx
>
>
> Maybe a fix would be to use this "5060" port, instead of hardcoding it
> like you did ?

Just posted v2... appreciate the advice so far.

My new code in process_sip_request() looks for an address match + port
mismatch between the IP source and the Via: header.  This is how it
tries to detect whether we are talking directly to an afflicted Cisco
phone.  If the address doesn't match, I assume the request is passing
through a non-SIP-aware NAT router so there is no special handling.

Assuming we can reliably detect the "quirky phone" condition, is there
any way to just trick Netfilter into thinking the source port was 5060
instead of 49xxx?  3/4ths of the patch could probably be eliminated if
we could overwrite the port number inside tuplehash.
