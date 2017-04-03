From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Mon, 3 Apr 2017 23:12:14 +0530
Message-ID: <CA+sq2Ce5HgtxZAFNsA+rAgf2-VXfJQkFDWXdQ-L8aVaVvqTofg@mail.gmail.com>
References: <20170313195804.GA1796@felix2.cavium.com> <CA+sq2CdG9fBR-Hw3rULMJON3aFQkCXtEpgkfKTzYhd5s=Lo1Tw@mail.gmail.com>
 <CY1PR07MB2665225225D98B5366576AA3EC080@CY1PR07MB2665.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Ricardo Farrington <Ricardo.Farrington@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:36025 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdDCRmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 13:42:16 -0400
Received: by mail-wr0-f176.google.com with SMTP id w11so178335135wrc.3
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 10:42:16 -0700 (PDT)
In-Reply-To: <CY1PR07MB2665225225D98B5366576AA3EC080@CY1PR07MB2665.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 3, 2017 at 8:33 PM, Ricardo Farrington
<Ricardo.Farrington@cavium.com> wrote:
> Hi Sunil - this implementation was verified with multiple adapters installed.  In this case, the <id> field serves to differentiate the adapter.
>
>>     LiquidIO<id>-<func>-<type>-<queue pair num>
>
> Rick
>

No, what I was referring to was, let's say there are two adapters, if
we do a unbind of driver and
then bind driver in reverse sequence, then the <id> of each adapter
will get exchanged. isn't it ?

If the above is true, the logical interface's name will still be the
same but the <id> is different,
so it's not easy to map a logical interface to it's registered IRQs,
hence doing affinity setting is still problematic.

But moreover it seems the driver is calling 'octeon_allocate_device()'
for each VF, so not sure how <id> field which
is derived from 'oct->octeon_id' helps in differentiating the adapter.
Is there only one VF per adapter ?

821 static int
822 liquidio_vf_probe(struct pci_dev *pdev,
823                   const struct pci_device_id *ent __attribute__((unused)))
824 {
825         struct octeon_device *oct_dev = NULL;
826
827         oct_dev = octeon_allocate_device(pdev->device,
828                                          sizeof(struct octeon_device_priv));
829

Thanks,
Sunil.
