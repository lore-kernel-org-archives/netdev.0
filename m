From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH v3 net-next 1/9] sunvnet: make sunvnet common code
 dynamically loadable
Date: Mon, 13 Feb 2017 09:16:08 -0800
Message-ID: <cdc2ede8-5590-e8a2-00bf-d434bbe617a6@oracle.com>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
 <1486748305-240339-2-git-send-email-shannon.nelson@oracle.com>
 <d4146a2e-2fc2-3c48-fedf-9f42b52800a0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <d4146a2e-2fc2-3c48-fedf-9f42b52800a0@cogentembedded.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/12/2017 3:16 AM, Sergei Shtylyov wrote:
> Hello!
>
> On 2/10/2017 8:38 PM, Shannon Nelson wrote:
>
>> When the sunvnet_common code was split out for use by both sunvnet
>> and the newer ldmvsw, it was made into a static kernel library, which
>> limits the usefulness of sunvnet and ldmvsw as loadables, since most
>> of the real work is being done in the shared code.  Also, this is
>> simply dead code in kernels that aren't running the LDoms.
>>
>> This patch makes the sunvnet_common into a dynamically loadable
>> module and makes sunvnet and ldmvsw dependent on sunvnet_common.
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
>> ---
>>  drivers/net/ethernet/sun/Kconfig          |    8 ++++++--
>>  drivers/net/ethernet/sun/sunvnet_common.c |    5 +++++
>>  2 files changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/sun/Kconfig
>> b/drivers/net/ethernet/sun/Kconfig
>> index a4b40e3..a7d91da 100644
>> --- a/drivers/net/ethernet/sun/Kconfig
>> +++ b/drivers/net/ethernet/sun/Kconfig
>> @@ -70,19 +70,23 @@ config CASSINI
>>
>> <http://docs.oracle.com/cd/E19113-01/giga.ether.pci/817-4341-10/817-4341-10.pdf>.
>>
>>
>>  config SUNVNET_COMMON
>> -    bool
>> +    tristate "Common routines to support Sun Virtual Networking"
>>      depends on SUN_LDOMS
>> -    default y if SUN_LDOMS
>> +    default m if SUN_LDOMS
>
>    Sounds tautological... maybe just "default m"?

Yep, that can be tightened up.

Thanks,
sln

