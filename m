From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next] bnxt: add dma mapping attributes
Date: Tue, 9 May 2017 15:54:48 -0700
Message-ID: <b8fb7775-9074-b730-d464-b37f36101676@oracle.com>
References: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
 <CACKFLikw_oi4rHRC9P-23xuvuOJSaf9b2kUSeTMgbNW1WA__=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, sparclinux@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <CACKFLikw_oi4rHRC9P-23xuvuOJSaf9b2kUSeTMgbNW1WA__=w@mail.gmail.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/9/2017 2:05 PM, Michael Chan wrote:
> On Tue, May 9, 2017 at 1:37 PM, Shannon Nelson
> <shannon.nelson@oracle.com> wrote:
>> On the SPARC platform we need to use the DMA_ATTR_WEAK_ORDERING attribute
>> in our Rx path dma mapping in order to get the expected performance out
>> of the receive path.  Adding it to the Tx path has little effect, so
>> that's not a part of this patch.
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
>> Reviewed-by: Tushar Dave <tushar.n.dave@oracle.com>
>> Reviewed-by: Tom Saeger <tom.saeger@oracle.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnxt/bnxt.c |   61 ++++++++++++++++++----------
>>  1 files changed, 39 insertions(+), 22 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> index 1f1e54b..771742c 100644
>> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> @@ -66,6 +66,12 @@
>>  MODULE_DESCRIPTION("Broadcom BCM573xx network driver");
>>  MODULE_VERSION(DRV_MODULE_VERSION);
>>
>> +#ifdef CONFIG_SPARC
>> +#define BNXT_DMA_ATTRS  DMA_ATTR_WEAK_ORDERING
>> +#else
>> +#define BNXT_DMA_ATTRS 0
>> +#endif
>> +
>
> I think we can use the same attribute for all architectures.
> Architectures that don't implement weak ordering will ignore the
> attribute.
>

In the long run, you are probably correct, and it would be simple enough 
to change this.  However, given the recent threads about the 
applicability of Relaxed Ordering and a couple of PCIe root complexes 
that have been found to have issues with Relaxed Ordering TLPs, I prefer 
to stay on the conservative side and set it up only for the platform I 
know.  As it stands, this patch won't change the currently working 
behavior on other platforms, but will help us out on the one we know can 
use the feature.

sln


