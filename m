From: "John Que" <qwejohn@gmail.com>
Subject: Re: Two I/O memory regions in /proc/iomem for a NIC
Date: Sun, 2 Jul 2006 18:37:18 +0300
Message-ID: <ada605fb0607020837q5573299ke05864e130169bed@mail.gmail.com>
References: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
	 <20060702111224.GA6624@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:41708 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932361AbWGBPhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 11:37:20 -0400
Received: by nf-out-0910.google.com with SMTP id m19so448354nfc
        for <netdev@vger.kernel.org>; Sun, 02 Jul 2006 08:37:18 -0700 (PDT)
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <20060702111224.GA6624@havoc.gtf.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
Thanks for your answers.

I  checked again:  On the machine with e1000 driver, it was in fact a
machine with 2
e1000 NICs.

However, if I am not wrong, it happened I also saw 2 I/O regions on a
machine with one NIC
(RealTek 8139too) when typing cat /proc/iomem. I am not sure though.

Let me please rephrase my question:
As I understand , the NIC "probe" method is called only ONCE
(also when we have 2 NICs , which are identical so have the same
vendor ID; I hope I am not ).
So:
Could a single call to
pci_request_regions(pdev, driver_name)
result in that we see 2 regions afterwards when running
cat /proc/iomem?

As I understand, indeed this is the case.
Regards,
John




On 7/2/06, Jeff Garzik <jeff@garzik.org> wrote:
> On Sun, Jul 02, 2006 at 10:24:10AM +0300, John Que wrote:
> > Hello,
> >
> > I had noticed that there are machines where
> > if I ran cat /proc/iomem I see one I/O memory region for the NIC
> > I am using; while there are other machines where
> > I see 2 regions for the NIC I/O memory.
> >
> > For example, on a machine with e1000 NIC adapter,
> > I see the following 2 I/O memory regions for the NIC:
> > fc9a0000-fc9bffff : 0000:03:04.0
> >    fc9a0000-fc9bffff : e1000
> > fc9c0000-fc9dffff : 0000:03:03.0
> >    fc9c0000-fc9dffff : e1000
>
> There could be 1001 reasons.  Overall, it's not important :)
>
> e1000 driver will reserve all regions made available by the PCI device.
>
>         Jeff
>
>
>
>
