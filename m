From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 22:46:34 +0200
Message-ID: <m3ve27nfpx.fsf@maximus.localdomain>
References: <m3r6cv75xq.fsf@maximus.localdomain>
	<20080424.063006.153647297.davem@davemloft.net>
	<m3mynj74nw.fsf@maximus.localdomain>
	<20080424.065555.30390704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755033AbYDXUrB@vger.kernel.org>
In-Reply-To: <20080424.065555.30390704.davem@davemloft.net> (David Miller's message of "Thu\, 24 Apr 2008 06\:55\:55 -0700 \(PDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I would rather see you add small extensions to syncppp to
> provide for HDLC's needs, rather than reimplement it.

It's not about extensions, syncppp is just unmaintainable. It's
implementation of two protocols - Cisco HDLC and (sync) PPP intermixed
together.

What would be needed is a) splitting them into two files (including
protocol selection in drivers - somehow), b) replacing existing
broken syncppp state machines distributed all over the place with a
single sane state machine, c) perhaps adding IPv6, people want it,
d) packet flow from hw drivers would need to be upgraded as well
(*_type_trans() and fast path for IP/IPv6 and perhaps IPX, though
I don't know anyone ever using IPX with sync PPP).

I guess then you'd get generic HDLC.

I think it's easier to a) simply remove syncppp.c, b) apply my patch
with new PPP, c) blindly port the old drivers to generic HDLC,
d) hope for the best, with a bit of luck nobody would notice.

Alternative c) simply remove the old drivers (d) unchanged).

I don't want the breakage resulting from either action thus I think
syncppp.c should stay there (basically unchanged, though we could
at last remove those variables used only by the original FreeBSD
code in 1994).

If the new implementation is my patch or if it uses generic PPP is
debatable. I think simplicity is a good thing, the interface to
generic PPP would be bigger than the whole sync-only PPP. But I'm not
against using generic PPP, it's (AFAICS) clean and *working* and
*maintained* (and I'm not worried about backward compatibility and
certainly not about users' visions).
-- 
Krzysztof Halasa
