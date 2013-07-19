From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/2] Transmit time stamping on tun/tap interfaces
Date: Fri, 19 Jul 2013 19:40:08 +0200
Message-ID: <cover.1374254757.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47793 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab3GSRkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 13:40:23 -0400
Received: by mail-ee0-f46.google.com with SMTP id d41so2483860eek.19
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 10:40:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds transmit SO_TIMESTAMPING for tun and tap devices.
Having this support is useful for testing multiple instances of PTP
programs (for example, to exercise the best master clock behavior)
and for synchronizing virtual guests.

The first patch refactors the code that delivers raw error queue
packets into a common function, in order to avoid multiple, nearly
identical implementations. This can be used whenever a network layer
has an error queue for transmit time stamp reporting only.

Thanks,
Richard


Richard Cochran (2):
  Provide a generic socket error queue delivery method for Tx time
    stamps.
  tun: Support software transmit time stamping.

 drivers/net/tun.c           |   14 +++++++++++--
 include/net/sock.h          |    2 ++
 include/uapi/linux/if_tun.h |    3 +++
 net/core/sock.c             |   47 ++++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c      |   48 ++-----------------------------------------
 5 files changed, 66 insertions(+), 48 deletions(-)

-- 
1.7.10.4
