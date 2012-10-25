From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next 00/15] 6lowpan: Some more bug fixes
Date: Thu, 25 Oct 2012 08:52:40 +0400
Message-ID: <CAJmB2rDcdo7r-0xoNnrbXRB4KKWoKJmpu9OTk5HHuE1V5Py2qA@mail.gmail.com>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:53047 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab2JYEwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 00:52:41 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so1463046vbb.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 21:52:41 -0700 (PDT)
In-Reply-To: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2012/10/23 Tony Cheneau <tony.cheneau@amnesiak.org>:
> Hello,
>
> This patch serie fixes a few bugs within the 6lowpan modules and prepares the
> integration of the serial driver that will be submitted in a subsequent patch serie.
> It should apply cleanly on the latest net-next.

1. The series is quite huge what makes it difficult for the review. It
would be better to split it into one-two and submit separately (not
simultaneously).
2. Could you also please provide some notes about how have you tested
these changes (logs, plain text)? Do I need to check your changes
locally on my desk? If so I need some instructions.
3. Please DO NOT submit patches like: this patch fixes blablabla which
isn't in the kernel yet (like patch 13,15). I have no clue what you
have locally on your laptop and what you will send in some time. I'd
like to see here the working code, not a references to TBD.
4. The reference to linux-zigbee project isn't an occasion for me to
apply this code to this tree. I have no goal to merge all this fun to
mainline due to several things in linux-zigbee kernel work NOT
according to the standard (mostly it's a timing problems) and global
refactoring needed.

Alex

>
> Regards,
>         Tony Cheneau
>
> Tony Cheneau (15):
>   6lowpan: lowpan_is_iid_16_bit_compressable() does not detect
>     compressable address correctly
>   6lowpan: next header is not properly set upon decompression of a UDP
>     header.
>   6lowpan: always enable link-layer acknowledgments
>   mac802154: turn on ACK when enabled by the upper layers
>   6lowpan: use short IEEE 802.15.4 addresses for broadcast destination
>   6lowpan: fix first fragment (FRAG1) handling
>   6lowpan: store fragment tag values per device instead of net stack
>     wide
>   6lowpan: obtain IEEE802.15.4 sequence number from the MAC layer
>   6lowpan: add a new parameter in sysfs to turn on/off ACK request at
>     MAC layer
>   6lowpan: use the PANID provided by the device instead of a static
>     value
>   6lowpan: modify udp compression/uncompression to match the standard
>   6lowpan: make memory allocation atomic during 6lowpan header creation
>   mac802154: make mem alloc ATOMIC to prevent "scheduling while atomic"
>     crashes
>   mac802154: remove unnecessary spinlocks
>   mac802154: re-introduce MAC primitives required to send/receive
>     packets
>
>  net/ieee802154/6lowpan.c  |  144 ++++++++++++++++++++++++++++++++++++---------
>  net/ieee802154/6lowpan.h  |   14 +++--
>  net/mac802154/mac802154.h |    2 +
>  net/mac802154/mac_cmd.c   |   22 +++++++-
>  net/mac802154/mib.c       |   33 +++++++----
>  net/mac802154/wpan.c      |    4 +-
>  6 files changed, 172 insertions(+), 47 deletions(-)
>
> --
> 1.7.8.6
>
