From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] esp4/6: Fix GSO path for non-GSO SW-crypto
 packets
Date: Thu, 20 Apr 2017 07:16:46 +0200
Message-ID: <20170420051645.GA3976@secunet.com>
References: <20170419054101.16738-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Boris Pismenny <borisp@mellanox.com>,
        "Yevgeny Kliteynik" <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>
To: <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45190 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764847AbdDTFRP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 01:17:15 -0400
Content-Disposition: inline
In-Reply-To: <20170419054101.16738-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 08:41:01AM +0300, ilant@mellanox.com wrote:
> From: Ilan Tayari <ilant@mellanox.com>
> 
> If esp*_offload module is loaded, outbound packets take the
> GSO code path, being encapsulated at layer 3, but encrypted
> in layer 2. validate_xmit_xfrm calls esp*_xmit for that.
> 
> esp*_xmit was wrongfully detecting these packets as going
> through hardware crypto offload, while in fact they should
> be encrypted in software, causing plaintext leakage to
> the network, and also dropping at the receiver side.
> 
> Perform the encryption in esp*_xmit, if the SA doesn't have
> a hardware offload_handle.
> 
> Also, align esp6 code to esp4 logic.
> 
> Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
> Fixes: 383d0350f2cc ("esp6: Reorganize esp_output")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Applied to ipsec-next, thanks Ilan!
