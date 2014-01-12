From: sowmini varadhan <sowmini05@gmail.com>
Subject: a vxlan question.
Date: Sun, 12 Jan 2014 12:25:51 -0500
Message-ID: <CACP96tSOA70sAE_b-Ff6=gOySg0sHQQMRwpuNaA1n5HvgFAzSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: sowmini.varadhan@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:64824 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaALRZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 12:25:52 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so4499831lab.37
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 09:25:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A question about the vxlan implementation in linux:

if the inner packet (the frame that is vxlan encapsulated) is an IP
packet that has the DF bit set, i.e., it is a PMTU discovery packet, and
the subsequent vxlan encapsulation results in a ICMP packet-too-big
error,then does the VTEP relay that error back to the originator of
the
PMTU packet?

AFAICT, the current linux code in drivers/net/vxlan.c
does not address any icmp errors (though it sets the DF of the outer
header based on the inner header). From my reading of the code,
we'd end up in __udp4_lib_err for the vxlan-encaps packet, but
there's nothing in there that recognizes that the udp payload is
itself an ethernet+IP frame and relays pmtu back to the (inner) ip src?
Did I miss something?

--Sowmini
