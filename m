From: Chris Verges <cverges@sentient-energy.com>
Subject: Established sockets remain open after iface down or address lost
Date: Wed, 25 Sep 2013 23:04:34 -0700
Message-ID: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:49496 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3IZGEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 02:04:38 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so680958pdj.30
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 23:04:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I've encountered a behavior that appears to be known, but am seeking
some clarity on its rationale.  The scenario is as follows:

  (0) A TCP server socket listens on :: (v4/v6).
  (1) Connect a USB/Ethernet adapter to a Linux system.
  (2) Adapter is brought up as 'eth0' with an IP address.
  (3) A remote TCP client connects to the server socket.
  (4) 'netstat -anp' shows the socket as ESTABLISHED
  (5) The TCP server starts a blocking read waiting for data.
  (6) Physically disconnect the USB/Ethernet adapter from the USB bus.
  (7) Linux removes the 'eth0' interface and associated IP address.

At this point, the socket _still_ shows as ESTABLISHED under netstat.

This is the paradox.  Why is the blocking read not interrupted with a
socket error to indicate that the socket is no longer viable?

Thank you in advance,
Chris

P.S.  I apologize in advance if I missed this answer in the netdev
archives.
