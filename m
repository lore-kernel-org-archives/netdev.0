From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Fri, 6 Mar 2009 23:18:22 -0800
Message-ID: <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com>
References: <49B1F934.5050006@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:4775 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbZCGHSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 02:18:25 -0500
In-Reply-To: <49B1F934.5050006@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>
> Impact: could probe igb
>
> Found one system with 82575EB, in the kernel that is kexeced, probe i=
gb
> failed with -2.
>
> it looks like the same behavior happened on forcedeth.
>
> try to check system_state to make sure if put it on D3
>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>
> ---
> =A0drivers/net/igb/igb_main.c | =A0 19 ++++++++++++++-----
> =A01 file changed, 14 insertions(+), 5 deletions(-)

I see the point of the patch, but I know for a fact that ixgbe when
enabled for MSI-X also doesn't work with kexec.

so my questions are:
are you going to change every driver?
why can't this be fixed in core kernel code instead?
Shouldn't pci_enable_device take it out of D3?
Or maybe it should be taken out of D3 immediately if someone tries to
ioremap any of the BARx registers?

Jesse
