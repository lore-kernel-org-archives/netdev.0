From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: pcie_get_minimum_link returns 0 width
Date: Mon, 26 Aug 2013 17:57:34 -0600
Message-ID: <CAErSpo68LaevaBG8rJD0aj+oy-cp_f2ZsQVEhXL=oUyyRiYwZw@mail.gmail.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com> <979A8436335E3744ADCD3A9F2A2B68A52AD13D0C@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:53831 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab3HZX5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 19:57:55 -0400
Received: by mail-ie0-f173.google.com with SMTP id qa5so2522762ieb.4
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 16:57:54 -0700 (PDT)
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AD13D0C@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 5:36 PM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
>> > Hi,
>> >
>> > I tried adding support for the newly added 'pcie_get_minimum_link' into
>> the
>> > bnx2x driver, but found out the some of my devices started showing width
>> x0.
>> >
>> > By adding debug prints, I've found out there were devices up the chain that
>> > Showed 0 when their PCI_EXP_LNKSTA was read by said function.
>> > However, when I tried looking via lspci the output claimed the width was
>> x4.
>>
>> I don't see a 'pcie_get_minimum_link()' function in my current tree
>> (git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git "next"
>> branch).  Maybe seeing your patch (with the debug prints) would give
>> me a hook for somewhere to start looking.
>
> You've acked the patch and it was applied in net-next; Obviously it has yet
> to migrate to your tree.

Oh, yeah, that's right.  I knew it sounded familiar, but I didn't
remember where it went.

Looking at its implementation, one obvious difference is that
pcie_get_minimum_link() traverses up the hierarchy and keeps track of
the minimum values it finds.  lspci, on the other hand, just reads
PCI_EXP_LNKSTA from a single device and decodes it.

You said lspci reports x4 for every device from the Root Port all the
way down to your NIC, so I would think the minimum from
pcie_get_minimum_link() would be x4.  But apparently it's not.  Maybe
there's a bug in it.  Can you post the complete "lspci -vv" output
along with your debug patch and output?

Bjorn
