From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH RFC 0/2] tcp: allow to repair a tcp connections in closing states
Date: Fri, 11 Apr 2014 00:25:37 +0400
Message-ID: <1397161539-27804-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26134 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934020AbaDJU0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 16:26:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently connections only in the TCP_ESTABLISHED state can be dumped and
restored. This series allows to restore connections in the FIN_WAIT_1,
FIN_WAIT_2, LAST_ACK, CLOSE_WAIT, CLOSING or TIME_WAIT states.

v2: We decide to not use control message for repairing fin packets in
queues. Because it looks quite tricky. Alexey suggested to restore each
state separately and in this case setsockopt looks more logical.

Andrey Vagin (2):
  tcp: allow to enable repair mode for sockets in closing states
  tcp: add ability to restore closing states (v2)

 include/uapi/linux/tcp.h |  1 +
 net/ipv4/tcp.c           | 75 ++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 71 insertions(+), 5 deletions(-)

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
