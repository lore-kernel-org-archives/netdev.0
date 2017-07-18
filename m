From: Ricardo Farrington <Ricardo.Farrington@cavium.com>
Subject: RE: [PATCH v2 net-next 0/3] liquidio: avoid vm low memory crashes
Date: Tue, 18 Jul 2017 15:08:49 +0000
Message-ID: <CY1PR07MB26658DEEECB90656C84658EAECA10@CY1PR07MB2665.namprd07.prod.outlook.com>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
 <20170718062317.GJ3259@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Leon Romanovsky <leon@kernel.org>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:47600
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751441AbdGRPI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 11:08:57 -0400
In-Reply-To: <20170718062317.GJ3259@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My apologies Leon - I did not infer that the subject line should have been =
changed from your previous correspondence.  I will correct it.

Rick

-----Original Message-----
From: Leon Romanovsky [mailto:leon@kernel.org]=20
Sent: Monday, July 17, 2017 11:23 PM
To: Manlunas, Felix <Felix.Manlunas@cavium.com>
Cc: davem@davemloft.net; netdev@vger.kernel.org; Vatsavayi, Raghu <Raghu.Va=
tsavayi@cavium.com>; Chickles, Derek <Derek.Chickles@cavium.com>; Burla, Sa=
tananda <Satananda.Burla@cavium.com>; Ricardo Farrington <Ricardo.Farringto=
n@cavium.com>
Subject: Re: [PATCH v2 net-next 0/3] liquidio: avoid vm low memory crashes

On Mon, Jul 17, 2017 at 05:49:20PM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> This patchset addresses issues brought about by low memory conditions=20
> in a VM.  These conditions were not seen when the driver was exercised=20
> normally.  Rather, they were brought about through manual fault injection=
.
> They are being included in the interest of hardening the driver=20
> against unforeseen circumstances.
>
> 1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list=
'.
>    This prevents a GPF trying to access an invalid 'recv_buf_list[i]' ent=
ry
>    in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries=
.
> 2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
> 3. For defensive programming, zero the allocated block 'oct->droq[0]' in
>    octeon_setup_output_queues() and 'oct->instr_queue[0]' in
>    octeon_setup_instr_queues().
>
> change log:
> V1 -> V2:
> 1. Corrected syntax in 'Subject' lines; no functional or code changes.
>
> Rick Farrington (3):
>   liquidio: lowmem: init allocated memory to 0
>   liquidio: lowmem: do not dereference null ptr
>   liquidio: lowmem: init allocated memory to 0

I'm feeling d=E9j=E0 vu here. We already discussed that zero allocated arra=
ys have nothing to do with low memory conditions. Why are you continuing to=
 use this misleading term here?

>
>  drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.c   | 6 ++++--
>  2 files changed, 8 insertions(+), 6 deletions(-)
>
> --
> 2.9.0
>
