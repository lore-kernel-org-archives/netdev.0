From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: [PATCH] vxge: Declare MODULE_FIRMWARE usage
Date: Fri, 27 Jul 2012 07:06:47 -0600
Message-ID: <50129267.7000504@canonical.com>
References: <1343329710-96747-1-git-send-email-tim.gardner@canonical.com> <CAPoiz9xoMF23FQOJjJviZjA-Db6Bhc9iQLPHTpFNX1USF4Oazw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPoiz9xoMF23FQOJjJviZjA-Db6Bhc9iQLPHTpFNX1USF4Oazw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2012 01:55 PM, Jon Mason wrote:
> On Thu, Jul 26, 2012 at 12:08 PM, Tim Gardner <tim.gardner@canonical.com> wrote:
>> Cc: Jon Mason <jdmason@kudzu.us>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Joe Perches <joe@perches.com>
>> Cc: Jiri Pirko <jpirko@redhat.com>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
>> ---
>>   drivers/net/ethernet/neterion/vxge/vxge-main.c |    9 +++++++--
>>   1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> index de21904..d4832b2 100644
>> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> @@ -4203,6 +4203,9 @@ out:
>>          return ret;
>>   }
>>
>> +#define VXGE_PXE_FIRMWARE "vxge/X3fw-pxe.ncf"
>> +#define VXGE_FIRMWARE "vxge/X3fw.ncf"
>> +
>>   static int vxge_probe_fw_update(struct vxgedev *vdev)
>>   {
>>          u32 maj, min, bld;
>> @@ -4245,9 +4248,9 @@ static int vxge_probe_fw_update(struct vxgedev *vdev)
>>                          }
>>          }
>>          if (gpxe)
>> -               fw_name = "vxge/X3fw-pxe.ncf";
>> +               fw_name = VXGE_PXE_FIRMWARE;
>>          else
>> -               fw_name = "vxge/X3fw.ncf";
>> +               fw_name = VXGE_FIRMWARE;
>>
>>          ret = vxge_fw_upgrade(vdev, fw_name, 0);
>>          /* -EINVAL and -ENOENT are not fatal errors for flashing firmware on
>> @@ -4855,3 +4858,5 @@ vxge_closer(void)
>>   }
>>   module_init(vxge_starter);
>>   module_exit(vxge_closer);
>> +MODULE_FIRMWARE(VXGE_PXE_FIRMWARE);
>> +MODULE_FIRMWARE(VXGE_FIRMWARE);
>
> IIUC, MODULE_FIRMWARE is only necessary for devices that need firmware
> to operate.  vxge hardware has an image in flash on the nic, and the
> modified code is used to update the firmware image on the adapter.
> So, this change isn't doing what you want it to do.
>
> Also, wasn't this already discussed (https://lkml.org/lkml/2012/4/12/401)?
>
> Thanks,
> Jon
>

Hmm, I'd forgotten about that discussion, but its no more correct now 
then it was then. MODULE_FIRMWARE is purely informational and has _no_ 
runtime impact. It is merely an indicator that a firmware file _might_ 
be used by the kernel and should therefore be left in the external 
firmware package. MODULE_FIRMWARE() uses the same base MODULE_INFO macro 
as MODULE_VERSION, MODULE_AUTHOR, MODULE_LICENSE, etc.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
