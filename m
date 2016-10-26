From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] packet: on direct_xmit, limit tso and csum to supported
 devices
Date: Wed, 26 Oct 2016 12:47:22 +0200
Message-ID: <581089BA.4090309@iogearbox.net>
References: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39901 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752353AbcJZKr0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 06:47:26 -0400
In-Reply-To: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2016 02:28 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> When transmitting on a packet socket with PACKET_VNET_HDR and
> PACKET_QDISC_BYPASS, validate device support for features requested
> in vnet_hdr.
>
> Drop TSO packets sent to devices that do not support TSO or have the
> feature disabled. Note that the latter currently do process those
> packets correctly, regardless of not advertising the feature.
>
> Because of SKB_GSO_DODGY, it is not sufficient to test device features
> with netif_needs_gso. Full validate_xmit_skb is needed.
>
> Switch to software checksum for non-TSO packets that request checksum
> offload if that device feature is unsupported or disabled. Note that
> similar to the TSO case, device drivers may perform checksum offload
> correctly even when not advertising it.
>
> When switching to software checksum, packets hit skb_checksum_help,
> which has two BUG_ON checksum not in linear segment. Packet sockets
> always allocate at least up to csum_start + csum_off + 2 as linear.

Ok, for the tpacket_fill_skb() case with SOCK_RAW, it's guaranteed,
because if we have a vnet header, then copylen would cover that here
(as opposed to just dev->hard_header_len). With Eric's suggestion,
looks good to me. Thanks, Willem!
