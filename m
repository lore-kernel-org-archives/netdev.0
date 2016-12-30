From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Fri, 30 Dec 2016 16:33:47 -0500
Message-ID: <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:33470 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752421AbcL3Ve3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 16:34:29 -0500
Received: by mail-ua0-f195.google.com with SMTP id d5so18600241uag.0
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 13:34:28 -0800 (PST)
In-Reply-To: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 11:54 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Although TPACKET_V3 Rx has some benefits over TPACKET_V2 Rx,
> *_v3 does not currently have Tx support. As a result an application
> that wants the best perf for Tx and Rx (e.g. to handle
> request/response transacations) ends up needing 2 sockets,
> one with *_v2 for Tx and another with *_v3 for Rx.
>
> This patch enables TPACKET_V2 compatible Tx features in TPACKET_V3
> so that _v3 supports at least as many features as _v2.

Once we define the interface as equivalent to v2, we cannot redefine it to
support v3-only features later.

> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  Documentation/networking/packet_mmap.txt |    6 ++++--
>  net/packet/af_packet.c                   |   23 +++++++++++++++--------
>  2 files changed, 19 insertions(+), 10 deletions(-)
>
> diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
> index daa015a..6425062 100644
> --- a/Documentation/networking/packet_mmap.txt
> +++ b/Documentation/networking/packet_mmap.txt
> @@ -565,7 +565,7 @@ where 'tpacket_version' can be TPACKET_V1 (default), TPACKET_V2, TPACKET_V3.
>                    (void *)hdr + TPACKET_ALIGN(sizeof(struct tpacket_hdr))
>
>  TPACKET_V2 --> TPACKET_V3:
> -       - Flexible buffer implementation:
> +       - Flexible buffer implementation for RX_RING:
>                 1. Blocks can be configured with non-static frame-size

This is one of the main advantages of the v3 interface, and also
relevant to Tx. The current implementation does not consult
tpacket3_hdr->tp_next_offset and would preclude adding that
later.
