From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next] bnxt: add dma mapping attributes
Date: Tue, 9 May 2017 18:17:05 -0700
Message-ID: <9dde0a3e-6f87-6571-afe3-9aa36635a874@oracle.com>
References: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
 <20170509.204937.115947896476049334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170509.204937.115947896476049334.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/9/2017 5:49 PM, David Miller wrote:
> From: Shannon Nelson <shannon.nelson@oracle.com>
> Date: Tue,  9 May 2017 13:37:33 -0700
>
>> @@ -66,6 +66,12 @@
>>  MODULE_DESCRIPTION("Broadcom BCM573xx network driver");
>>  MODULE_VERSION(DRV_MODULE_VERSION);
>>
>> +#ifdef CONFIG_SPARC
>> +#define BNXT_DMA_ATTRS  DMA_ATTR_WEAK_ORDERING
>> +#else
>> +#define BNXT_DMA_ATTRS	0
>> +#endif
>> +
>
> I do not what this ifdef crap showing up in every driver just
> to improve performance on one platform.
>
> This needs to be generically done somehow in a way that
> drivers get the correct setting automatically and without
> ifdef checks.
>

Yes, these do get ugly, and as Michael pointed out this really is an 
advisory bit and should just be ignored by platforms that don't care. 
I'll just respin this using the DMA_ATTR_WEAK_ORDERING bit directly 
rather than obscuring it with a BNXT define.

sln
