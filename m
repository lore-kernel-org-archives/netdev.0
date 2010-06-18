From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] e1000e: don't inadvertently re-set
	INTX_DISABLE
Date: Fri, 18 Jun 2010 14:14:42 -0700
Message-ID: <AANLkTilRc85LGk0ZIyUy9zOpddRCnzYnlfrlS1JNB-Ya@mail.gmail.com>
References: <20100618203630.5781.77777.send-patch@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63371 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab0FRVOn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 17:14:43 -0400
Received: by iwn9 with SMTP id 9so1461395iwn.19
        for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 14:14:42 -0700 (PDT)
In-Reply-To: <20100618203630.5781.77777.send-patch@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 13:36, Dean Nelson <dnelson@redhat.com> wrote:
> Should e1000_test_msi() fail to see an msi interrupt, it attempts to
> fallback to legacy INTx interrupts. But an error in the code may prev=
ent
> this from happening correctly.
>
> Before calling e1000_test_msi_interrupt(), e1000_test_msi() disables =
SERR
> by clearing the SERR bit from the just read PCI_COMMAND bits as it wr=
ites
> them back out.
>
> Upon return from calling e1000_test_msi_interrupt(), it re-enables SE=
RR
> by writing out the version of PCI_COMMAND it had previously read.
>
> The problem with this is that e1000_test_msi_interrupt() calls
> pci_disable_msi(), which eventually ends up in pci_intx(). And becaus=
e
> pci_intx() was called with enable set to 1, the INTX_DISABLE bit gets
> cleared from PCI_COMMAND, which is what we want. But when we get back=
 to
> e1000_test_msi(), the INTX_DISABLE bit gets inadvertently re-set beca=
use
> of the attempt by e1000_test_msi() to re-enable SERR.
>
> The solution is to have e1000_test_msi() re-read the PCI_COMMAND bits=
 as
> part of its attempt to re-enable SERR.
>
> During debugging/testing of this issue I found that not all the syste=
ms
> I ran on had the SERR bit set to begin with. And on some of the syste=
ms
> the same could be said for the INTX_DISABLE bit. Needless to say thes=
e
> latter systems didn't have a problem falling back to legacy INTx
> interrupts with the code as is.
>
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> CC: stable@kernel.org
>
> ---
>
> I forced the msi interrupt test to fail by commenting out the clearin=
g
> of FLAG_MSI_TEST_FAILED in e1000_intr_msi_test().
>
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 13 +++++++++----
> =C2=A01 files changed, 9 insertions(+), 4 deletions(-)
>

Thanks Dean, I have added it to my queue.

Cheers,
Jeff
