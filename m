From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/5] tg3: Convert to use
	hwmon_device_register_with_groups
Date: Mon, 25 Nov 2013 18:47:48 -0800
Message-ID: <52940BD4.9000605@roeck-us.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385186881-7931-2-git-send-email-linux@roeck-us.net>
	<5293FEFA.4000700@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	lm-sensors@lm-sensors.org, Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nithin Nayak Sujir <nsujir@broadcom.com>, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5293FEFA.4000700@broadcom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11/25/2013 05:52 PM, Nithin Nayak Sujir wrote:
>
>
> On 11/22/2013 10:07 PM, Guenter Roeck wrote:
>> Use new hwmon API to simplify code, provide missing mandatory 'name'
>> sysfs attribute, and attach hwmon attributes to hwmon device instead
>> of pci device.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>>   drivers/net/ethernet/broadcom/tg3.c |   25 ++++++-------------------
>>   1 file changed, 6 insertions(+), 19 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
>> index a9e0684..369b736 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -10629,10 +10629,8 @@ static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
>>   static ssize_t tg3_show_temp(struct device *dev,
>>                    struct device_attribute *devattr, char *buf)
>>   {
>> -    struct pci_dev *pdev = to_pci_dev(dev);
>> -    struct net_device *netdev = pci_get_drvdata(pdev);
>> -    struct tg3 *tp = netdev_priv(netdev);
>>       struct sensor_device_attribute *attr = to_sensor_dev_attr(devattr);
>> +    struct tg3 *tp = dev_get_drvdata(dev);
>
>
> Shouldn't this be
> struct tg3 *tp = netdev_priv(dev_get_drvdata(dev));
>

'struct tg3 *tp' is attached to the hwmon device in
hwmon_device_register_with_groups(), so it can be retrieved
with dev_get_drvdata() from there. Keep in mind that 'dev'
is no longer the pci device but the hwmon device.

Guenter



------------------------------------------------------------------------------
Shape the Mobile Experience: Free Subscription
Software experts and developers: Be at the forefront of tech innovation.
Intel(R) Software Adrenaline delivers strategic insight and game-changing 
conversations that shape the rapidly evolving mobile landscape. Sign up now. 
http://pubads.g.doubleclick.net/gampad/clk?id=63431311&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
