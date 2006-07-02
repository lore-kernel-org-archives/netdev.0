From: "John Que" <qwejohn@gmail.com>
Subject: Two I/O memory regions in /proc/iomem for a NIC
Date: Sun, 2 Jul 2006 10:24:10 +0300
Message-ID: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:37761 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751087AbWGBHYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 03:24:16 -0400
Received: by nf-out-0910.google.com with SMTP id k26so199081nfc
        for <netdev@vger.kernel.org>; Sun, 02 Jul 2006 00:24:10 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I had noticed that there are machines where
if I ran cat /proc/iomem I see one I/O memory region for the NIC
I am using; while there are other machines where
I see 2 regions for the NIC I/O memory.

For example, on a machine with e1000 NIC adapter,
I see the following 2 I/O memory regions for the NIC:
fc9a0000-fc9bffff : 0000:03:04.0
    fc9a0000-fc9bffff : e1000
fc9c0000-fc9dffff : 0000:03:03.0
    fc9c0000-fc9dffff : e1000

while on a machine with realtek 8139too NIC I see only one region:
ec103000-ec1030ff : 0000:00:0a.0
  ec103000-ec1030ff : 8139too

But when looking at the code of both NICs, there
is only one call to pci_request_regions(), which seems
quite similiar in both cases and is called only once;

see the call to pci_request_regions() in drivers/net/e1000/e1000_main.c
and in drivers/net/8139too.c.

Any idea why is this so ? can anybody say 3-4 sentences
about this ?

TIA,
-- John
