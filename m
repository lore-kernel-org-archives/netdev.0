From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: never linger on process exit
Date: Thu, 17 Jul 2014 12:16:53 +0200
Message-ID: <8B552C8E-08D7-4536-92CD-130AF58B1E9D@holtmann.org>
References: <1405412728-4706-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Linux Bluetooth mailing list
	<linux-bluetooth@vger.kernel.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:59265 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbaGQKQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:16:39 -0400
In-Reply-To: <1405412728-4706-1-git-send-email-vdavydov@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vladimir,

> If the current process is exiting, lingering on socket close will make
> it unkillable, so we should avoid it.
> 
> Reproducer:
> 
>  #include <sys/types.h>
>  #include <sys/socket.h>
> 
>  #define BTPROTO_L2CAP   0
>  #define BTPROTO_SCO     2
>  #define BTPROTO_RFCOMM  3
> 
>  int main()
>  {
>          int fd;
>          struct linger ling;
> 
>          fd = socket(PF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
>          //or: fd = socket(PF_BLUETOOTH, SOCK_DGRAM, BTPROTO_L2CAP);
>          //or: fd = socket(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_SCO);
> 
>          ling.l_onoff = 1;
>          ling.l_linger = 1000000000;
>          setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
> 
>          return 0;
>  }
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Gustavo Padovan <gustavo@padovan.org>
> Cc: Johan Hedberg <johan.hedberg@gmail.com>
> ---
> net/bluetooth/l2cap_sock.c  |    3 ++-
> net/bluetooth/rfcomm/sock.c |    3 ++-
> net/bluetooth/sco.c         |    6 ++++--
> 3 files changed, 8 insertions(+), 4 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
