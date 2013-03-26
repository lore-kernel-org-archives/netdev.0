From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH v2 net-next 00/12] 6lowpan: Some more bug fixes
Date: Tue, 26 Mar 2013 07:48:17 -0400
Message-ID: <51518B01.9060309@signal11.us>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tony Cheneau <tony.cheneau@amnesiak.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37762 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757217Ab3CZLsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:48:22 -0400
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2013 11:59 PM, Tony Cheneau wrote:
> This patchset fixes serious bugs within the 6LoWPAN modules. I wrote a script
> (available at [1]) to prove the issues are real.  One can try and see that
> without these patches, most of the test fail (e.g. packet dropped by the
> receiver or node crashing). With all patches applied, all tests succeed. The
> tests themselves are very basic: sending ICMP packets, sending UDP packets,
> sending TCP packets, varying size of the packets. This actually triggers some
> 6LoWPAN specific code, namely fragmentation, packet reassembly and header
> compression.
> 
> This code passed the checkpatch.pl tool with a few warnings, that I believe
> are OK. It should apply cleanly on the latest net-next.
> 

I and have been running some form of this patchset since October, and
have reviewed it several times.

Reviewed-by: Alan Ott <alan@signal11.us>
Tested-by: Alan Ott <alan@signal11.us>


> Regards,
> 	Tony Cheneau
> 
> [1]: https://github.com/tcheneau/linux802154-regression-tests
> 
> Tony Cheneau (12):
>   6lowpan: lowpan_is_iid_16_bit_compressable() does not detect
>     compressible address correctly
>   6lowpan: next header is not properly set upon decompression of a UDP
>     header.
>   6lowpan: always enable link-layer acknowledgments
>   mac802154: turn on ACK when enabled by the upper layers
>   6lowpan: use short IEEE 802.15.4 addresses for broadcast destination
>   6lowpan: fix first fragment (FRAG1) handling
>   6lowpan: add debug messages for 6LoWPAN fragmentation
>   6lowpan: store fragment tag values per device instead of net stack
>     wide
>   mac802154: re-introduce mac802154_dev_get_dsn()
>   6lowpan: obtain IEEE802.15.4 sequence number from the MAC layer
>   6lowpan: use the PANID provided by the device instead of a static
>     value
>   6lowpan: modify udp compression/uncompression to match the standard
> 
>  net/ieee802154/6lowpan.c  | 136 +++++++++++++++++++++++++++++++++++++---------
>  net/ieee802154/6lowpan.h  |   7 ++-
>  net/mac802154/mac802154.h |   1 +
>  net/mac802154/mac_cmd.c   |   1 +
>  net/mac802154/mib.c       |   9 +++
>  net/mac802154/wpan.c      |   2 +
>  6 files changed, 127 insertions(+), 29 deletions(-)
> 
