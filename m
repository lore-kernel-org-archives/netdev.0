From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] ixgbe: force to
 synchronize reporting "link on" and getting speed and duplex
Date: Thu, 24 Dec 2015 14:24:29 +0800
Message-ID: <567B8F9D.1090709@gmail.com>
References: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D67992504EB551@FMSMSX105.amr.corp.intel.com>
	<567B581B.6080608@gmail.com>
	<87618083B2453E4A8714035B62D67992504EC970@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Viswanathan, Ven \(Wind River\)" <venkat.viswanathan@windriver.com>,
	"Shteinbock,
	Boris \(Wind River\)" <boris.shteinbock@windriver.com>, "Bourg,
	Vincent \(Wind River\)" <vincent.bourg@windriver.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87618083B2453E4A8714035B62D67992504EC970@FMSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/24/2015 01:58 PM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>> Sent: Wednesday, December 23, 2015 6:28 PM
>> To: Tantilov, Emil S; Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson,
>> Shannon; Wyborny, Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak,
>> John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org;
>> netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>> Vincent (Wind River)
>> Subject: Re: [Intel-wired-lan] [PATCH 1/1] ixgbe: force to synchronize
>> reporting "link on" and getting speed and duplex
>>
>> On 12/23/2015 11:59 PM, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org]
>> On
>>>> Behalf Of zyjzyj2000@gmail.com
>>>> Sent: Tuesday, December 22, 2015 10:47 PM
>>>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>>>> Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John; Williams,
>> Mitch
>>>> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>>>> devel@lists.sourceforge.net
>>>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River);
>> Bourg,
>>>> Vincent (Wind River)
>>>> Subject: [Intel-wired-lan] [PATCH 1/1] ixgbe: force to synchronize
>>>> reporting "link on" and getting speed and duplex
>>>>
>>>> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>>>>
>>>> In X540 NIC, there is a time span between reporting "link on" and
>>>> getting the speed and duplex. To a bonding driver in 802.3ad mode,
>>>> this time span will make it not work well if the time span is big
>>>> enough. The big time span will make bonding driver change the state of
>>>> the slave device to up while the speed and duplex of the slave device
>>>> can not be gotten. Later the bonding driver will not have change to
>>>> get the speed and duplex of the slave device. The speed and duplex of
>>>> the slave device are important to a bonding driver in 802.3ad mode.
>>>>
>>>> To 82599_SFP NIC and other kinds of NICs, this problem does
>>>> not exist. As such, it is necessary for X540 to report"link on" when
>>>> the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>>>>
>>>> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>>>> ---
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 +++++++++++++++-
>>>> 1 file changed, 15 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> index aed8d02..cb9d310 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> @@ -6479,7 +6479,21 @@ static void ixgbe_watchdog_link_is_up(struct
>>>> ixgbe_adapter *adapter)
>>>> 	       (flow_rx ? "RX" :
>>>> 	       (flow_tx ? "TX" : "None"))));
>>>>
>>>> -	netif_carrier_on(netdev);
>>>> +	/*
>>>> +	 * In X540 NIC, there is a time span between reporting "link on"
>>>> +	 * and getting the speed and duplex. To a bonding driver in 802.3ad
>>>> +	 * mode, this time span will make it not work well if the time span
>>>> +	 * is big enough. To 82599_SFP NIC and other kinds of NICs, this
>>>> +	 * problem does not exist. As such, it is better for X540 to report
>>>> +	 * "link on" when the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>>>> +	 */
>>>> +	if ((hw->mac.type == ixgbe_mac_X540) &&
>>>> +	    (link_speed != IXGBE_LINK_SPEED_UNKNOWN)) {
>>>> +		netif_carrier_on(netdev);
>>>> +	} else {
>>>> +		netif_carrier_on(netdev);
>>>> +	}
>>>> +
>>>> 	ixgbe_check_vf_rate_limit(adapter);
>>>>
>>>> 	/* enable transmits */
>>>> --
>>>> 1.7.9.5
>>> NAK
>>>
>>> I have already submitted a patch that will address the issue with bonding
>> reporting
>>> unknown speed (in /proc/bonding/bondX) after the link is established due
>> to link flaps:
>>> http://patchwork.ozlabs.org/patch/552485/
>>>
>>> The bonding driver gets the speed from ethtool and this is where the
>> reporting needs
>>> to be fixed. The issue is that the bonding driver polls for
>> netif_carrier_ok() at a
>>> certain rate and as such will not be able to detect rapid link changes.
>> Thanks for your reply. The root cause is different from my problem. My
>> problem is that
>> "link up" is prior to "speed and duplex". That is, the physical NIC
>> reports "link up" while
> The "link up" event is a result of an LSC interrupt, the speed is
> determined as result of that interrupt by checking the LINKS register.
Hi,

Sorry. I do not agree with you. Please see the followings for details.

/**
  * ixgbe_watchdog_update_link - update the link status
  * @adapter: pointer to the device adapter structure
  * @link_speed: pointer to a u32 to store the link_speed
  **/
static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)

 From this function, link_up and link_speed is from watchdo poll.

Thanks for your reply.

Zhu Yanjun
> If the LINKS register reports link as unknown then that is the actual state
> of the PHY - meaning the device is re-negotiating the speed for some reason.
>
>> the speed is unknown at the same time. We can run "ethtool ethx" to
>> confirm it.
> Prior to my patch the ethtool call will read the LINKS register which can show
> speed as unknown due to a link flap (for example). You are seeing the momentary
> state of the device.
>
> If you are still seeing the bond reporting "unknown" speed after the patch I pointed
> out  please file a bug either through e1000.sf.net or via Intel support and provide
> detailed information about the bonding setup, the type of the link partner (switch
> model etc) and full dmesg from the failed scenario along with the output from
> /proc/bonding/bond0
>
> Thanks,
> Emil
>


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
