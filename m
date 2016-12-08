From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Thu, 8 Dec 2016 19:29:17 +0300
Message-ID: <22cd572b-b241-3d5e-0cfe-c4a2c7d0ebd0@cogentembedded.com>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/2016 03:28 PM, Sergei Shtylyov wrote:

>    Good to see that somebody cares still about this driver, one more task off
> my back. :-)
>
> On 12/07/2016 07:28 PM, Niklas Söderlund wrote:
>
>   You only enable the WOL support fo the R-Car gen2 chips but never say that
> explicitly, neither in the subject nor here.

    Some patch description wouldn't hurt here, especially with the way you 
implemented this support, e.g. RPM vs clk API -- that needs some explanation...

>> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
>> ---
>>  drivers/net/ethernet/renesas/sh_eth.c | 120 +++++++++++++++++++++++++++++++---
>>  drivers/net/ethernet/renesas/sh_eth.h |   4 ++
>>  2 files changed, 116 insertions(+), 8 deletions(-)

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 05b0dc5..3974046 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.h
>> b/drivers/net/ethernet/renesas/sh_eth.h
>> index d050f37..26c6620 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>> @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
>>      unsigned shift_rd0:1;    /* shift Rx descriptor word 0 right by 16 */
>>      unsigned rmiimode:1;    /* EtherC has RMIIMODE register */
>>      unsigned rtrate:1;    /* EtherC has RTRATE register */
>> +    unsigned magic:1;    /* EtherC have PMDE in ECMR and MPDIP in ECSIPR */
>
>    OK, e.g. RZ/A1 doesn't have these bits...

    However, I'd prefer that the comment be reworded as such:

/* EtherC has ECMR.PMDE and ECSR.MPD */

or

/* EtherC has ECMR_PMDE and ECSR_MPD */

MBR, Sergei
