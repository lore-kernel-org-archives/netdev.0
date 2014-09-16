From: Vlad Yasevich <vyasevich@gmail.com>
Subject: tg3 issue with tcp checksums and vlan packets
Date: Tue, 16 Sep 2014 12:43:21 -0400
Message-ID: <541868A9.7080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:42214 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaIPQnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:43:24 -0400
Received: by mail-qa0-f50.google.com with SMTP id dc16so144743qab.37
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:43:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant and Michael

I am seeing a strange issue with tg3 driver when I try to pass to it tcp packets
that have partial checksums and inline (non-accelerated) vlan header.

Looking at the packet at the receiver, it appears as if the tcp checksum is never
updated.  If I strip the vlan header and set vlan_tci, then everything works ok.

You can easily reproduce this by configuring 802.1ad vlans on top of tg3 device.
This will force software tagging, tg3 will not fix checksums and tcp connections
will not be established.

I've looked at tg3 driver and it doesn't look like it tries to pass any checksum
offsets to the nic/firmware.  So it looks like a possible firmware issue.

Can you please take a look.

Thanks
-vlad
