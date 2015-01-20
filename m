From: ethan zhao <ethan.zhao@oracle.com>
Subject: Re: [PATCH] i40e: don't enable and init FCOE by
 default when do PF reset
Date: Tue, 20 Jan 2015 10:05:39 +0800
Message-ID: <54BDB7F3.2020400@oracle.com>
References: <933BEC2E04D6A5458F4B0239FB547F9A34CCCD35@fmsmsx118.amr.corp.intel.com>
	<54B86DF8.3040206@oracle.com>
	<1421419628.2632.112.camel@jtkirshe-mobl>
	<54B9D082.9050601@oracle.com>
	<933BEC2E04D6A5458F4B0239FB547F9A34CCE42B@fmsmsx118.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"brian.maly@oracle.com" <brian.maly@oracle.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Parikh,
	Neerav" <neerav.parikh@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ethan Zhao <ethan.kernel@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dev, Vasu" <vasu.dev@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <933BEC2E04D6A5458F4B0239FB547F9A34CCE42B@fmsmsx118.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


On 2015/1/20 5:10, Dev, Vasu wrote:
>> -----Original Message-----
>> From: ethan zhao [mailto:ethan.zhao@oracle.com]
>> Sent: Friday, January 16, 2015 7:01 PM
>> To: Kirsher, Jeffrey T
>> Cc: Dev, Vasu; Ethan Zhao; Ronciak, John; Brandeburg, Jesse; Allan, Bruce W;
>> Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Vick, Matthew;
>> Williams, Mitch A; Parikh, Neerav; Linux NICS; e1000-
>> devel@lists.sourceforge.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; brian.maly@oracle.com
>> Subject: Re: [PATCH] i40e: don't enable and init FCOE by default when do PF
>> reset
>>
>> Vasu,
>>
>>     What' your idea about the v2, any suggestion ?  Jeff is looking forward to
>> see it.
>>
> Jeff was asking for v2 in response to your last comment as "disable FCOE as default configuration as a temporary step" but I think that is the fix and user should n't enable FCoE until they have FCoE enabled X710 FCoE with either fabric or VN2VN mode FCoE setup.
  As a Linux distro, we don't know users have FCoE capable X710 or not, 
so we couldn't disable the FCoE configuration
  by default in the released kernel except FCoE is officially not 
supported yet with X710, but if yes, fix those bugs I
  mentioned is the only choice.


Thanks,
Ethan


>
> Thanks,
> Vasu
>
>> Thanks,
>> Ethan
>>
>>
>> On 2015/1/16 22:47, Jeff Kirsher wrote:
>>> On Fri, 2015-01-16 at 09:48 +0800, ethan zhao wrote:
>>>> Vasu,
>>>>
>>>>       OK, disable FCOE as default configuration as a temporary step to
>>>> make it  work.
>>> Sounds like I should expect a v2 coming, correct?
>>>
>>>> Thanks,
>>>> Ethan
>>>>
>>>> On 2015/1/16 7:45, Dev, Vasu wrote:
>>>>>> -----Original Message-----
>>>>>> From: ethan zhao [mailto:ethan.zhao@oracle.com]
>>>>>> Sent: Tuesday, January 13, 2015 6:41 PM
>>>>>> To: Dev, Vasu
>>>>>> Cc: Ethan Zhao; Ronciak, John; Kirsher, Jeffrey T; Brandeburg,
>>>>>> Jesse; Allan, Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Rose,
>>>>>> Gregory V; Vick, Matthew; Williams, Mitch A; Parikh, Neerav; Linux
>>>>>> NICS; e1000- devel@lists.sourceforge.net; netdev@vger.kernel.org;
>>>>>> linux- kernel@vger.kernel.org; brian.maly@oracle.com
>>>>>> Subject: Re: [PATCH] i40e: don't enable and init FCOE by default
>>>>>> when do PF reset
>>>>>>
>>>>>> Vasu,
>>>>>>
>>>>>> On 2015/1/14 3:38, Dev, Vasu wrote:
>>>>>>>> -----Original Message-----
>>>>>>>>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>>>>>>>> b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>>>>>>>> index a5f2660..a2572cc 100644
>>>>>>>>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>>>>>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>>>>>>>> @@ -6180,9 +6180,12 @@ static void
>>>>>>>>>>> i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
>>>>>>>>>>>         }
>>>>>>>>>>>      #endif /* CONFIG_I40E_DCB */
>>>>>>>>>>>      #ifdef I40E_FCOE
>>>>>>>>>>> -   ret = i40e_init_pf_fcoe(pf);
>>>>>>>>>>> -   if (ret)
>>>>>>>>>>> -           dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", ret);
>>>>>>>>>>> +   if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
>>>>>>>>>>> +           ret = i40e_init_pf_fcoe(pf);
>>>>>>>>> Calling i40e_init_pf_fcoe() here conflicts with its
>>>>>>>> I40E_FLAG_FCOE_ENABLED pre-condition since
>>>>>> I40E_FLAG_FCOE_ENABLED is
>>>>>>>> set by very same i40e_init_pf_fcoe(), in turn i40e_init_pf_fcoe()
>>>>>>>> will never get called.
>>>>>>>>
>>>>>>>> I don't think so,  here ,i40e_reset_and_rebuild()  is not the
>>>>>>>> only and the first place that  i40e_init_pf_fcoe() is called, see
>>>>>>>> i40e_probe(), that is the first chance.
>>>>>>>>
>>>>>>>> i40e_probe()
>>>>>>>> -->i40e_sw_init()
>>>>>>>>          -->i40e_init_pf_fcoe()
>>>>>>>>
>>>>>>>> And the I40E_FLAG_FCOE_ENABLED is possible be set by
>>>>>>>> i40e_fcoe_enable() or i40e_fcoe_disable() interface before the
>>>>>>>> reset action is to be done.
>>>>>>>>
>>>>>>> It is set by i40e_init_pf_fcoe() and you are right that the
>>>>>>> modified call flow
>>>>>> by your patch won't impact setting of I40E_FLAG_FCOE_ENABLED
>> anyway
>>>>>> which could have prevented calling i40e_init_pf_fcoe() as I
>>>>>> described above, so this is not an issue with the patch.
>>>>>>>> BTW, the reason I post this patch is that we hit a bug, after
>>>>>>>> setup vlan, the PF is enabled to FCOE.
>>>>>>>>
>>>>>>> Then that BUG would still remain un-fixed and calling
>>>>>>> i40e_init_pf_fcoe()
>>>>>> under I40E_FLAG_FCOE_ENABLED  flag really won't affect call flow to
>>>>>> fix anything. I mean I40E_FLAG_FCOE_ENABLED  condition will be true
>>>>>> with "pf-
>>>>>>> hw.func_caps.fcoe == true" and otherwise calling
>>>>>>> i40e_init_pf_fcoe() simply
>>>>>> returns back early on after checking "pf->hw.func_caps.fcoe ==
>>>>>> false", so how that bug is fixed here by added
>> I40E_FLAG_FCOE_ENABLED  condition ?
>>>>>> What is the bug ?
>>>>>>      The func_caps.fcoe is assigned by following call path, under
>>>>>> our test environment,
>>>>>>
>>>>>>      i40e_probe()
>>>>>>       ->i40e_get_capabilities()
>>>>>>          ->i40e_aq_discover_capabilities()
>>>>>>             ->i40e_parse_discover_capabilities()
>>>>>>
>>>>>>      Or
>>>>>>
>>>>>>      i40e_reset_and_rebuild()
>>>>>>       ->i40e_get_capabilities()
>>>>>>         ->i40e_aq_discover_capabilities()
>>>>>>           ->i40e_parse_discover_capabilities()
>>>>>>
>>>>>>      Under our test environment, the "pf->hw.func_caps.fcoe" is
>>>>>> true. so if
>>>>>> i40e_reset_and_rebuild() is called for VLAN setup, ethtool diagnostic
>> test.
>>>>>>      And then i40e_init_pf_fcoe() is to be called,
>>>>>>
>>>>>>      While if (!pf->hw.func_caps.fcoe) wouldn't return,
>>>>>>
>>>>> I said it would return with "pf->hw.func_caps.fcoe == false" in my last
>> response, more details below.
>>>>>>      So  pf->flags is set to I40E_FLAG_FCOE_ENABLED.
>>>>>>
>>>>>>      With my patch,  i40e_init_pf_fcoe() is only called after
>>>>>> I40E_FLAG_FCOE_ENABLED is set before reset.
>>>>>>
>>>>>> Enable FCOE in i40e_probe() or not is another issue.
>>>>>>
>>>>> Nope since both cases we should do i40e_init_pf_fcoe() or don't based
>> on fcoe cap true or false.
>>>>> I don't have much to add as I described before with the your patch that
>> "calling i40e_init_pf_fcoe() under I40E_FLAG_FCOE_ENABLED  flag really
>> won't affect call flow to fix anything. I mean I40E_FLAG_FCOE_ENABLED
>> condition will be true with "pf->hw.func_caps.fcoe == true" and otherwise
>> calling i40e_init_pf_fcoe() simply returns back early on after checking "pf-
>>> hw.func_caps.fcoe == false".
>>>>> May be I'm missing something, I guess next either go with
>> CONFIG_I40E_FCOE disable as I suggested before and now it in upstream
>> kernel or we can have further off list discussion to fix the issue you are trying
>> to fix with the patch.
>>>>> Thanks,
>>>>> Vasu
>>>>>
>>>>>> Thanks,
>>>>>> Ethan
>>>>>>
>>>>>>
>>>>>>>>> Jeff Kirsher should be getting out a patch queued by me which
>>>>>>>>> adds
>>>>>>>> I40E_FCoE Kbuild option, in that FCoE is disabled by default and
>>>>>>>> user could enable FCoE only if needed, that patch would do same
>>>>>>>> of skipping
>>>>>>>> i40e_init_pf_fcoe() whether FCoE capability in device enabled or
>>>>>>>> not in default config.
>>>>>>>> The following patch will not fix the above issue -- configuration
>>>>>>>> of PF will be changed via reset.
>>>>>>>> How about the FCOE is configured and disabled by
>>>>>>>> i40e_fcoe_disable() , then reset happens ?
>>>>>>>>
>>>>>>> May be but if the BUG is due to FCoE being enabled then having it
>>>>>>> disabled
>>>>>> in config will avoid the bug for non FCoE config option and once
>>>>>> bug is understood then that has to be fixed for FCoE enabled config
>>>>>> also as I asked above.
>>>>>>> Thanks Ethan for detailed response.
>>>>>>> Vasu
>>>>>>>
>>>>>>>>>     From patchwork Wed Oct  2 23:26:08 2013
>>>>>>>>> Content-Type: text/plain; charset="utf-8"
>>>>>>>>> MIME-Version: 1.0
>>>>>>>>> Content-Transfer-Encoding: 7bit
>>>>>>>>> Subject: [net] i40e: adds FCoE configure option
>>>>>>>>> Date: Thu, 03 Oct 2013 07:26:08 -0000
>>>>>>>>> From: Vasu Dev <vasu.dev@intel.com>
>>>>>>>>> X-Patchwork-Id: 11797
>>>>>>>>>
>>>>>>>>> Adds FCoE config option I40E_FCOE, so that FCoE can be enabled
>>>>>>>>> as needed but otherwise have it disabled by default.
>>>>>>>>>
>>>>>>>>> This also eliminate multiple FCoE config checks, instead now
>>>>>>>>> just one config check for CONFIG_I40E_FCOE.
>>>>>>>>>
>>>>>>>>> The I40E FCoE was added with 3.17 kernel and therefore this
>>>>>>>>> patch shall be applied to stable 3.17 kernel also.
>>>>>>>>>
>>>>>>>>> CC: <stable@vger.kernel.org>
>>>>>>>>> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
>>>>>>>>> Tested-by: Jim Young <jamesx.m.young@intel.com>
>>>>>>>>>
>>>>>>>>> ---
>>>>>>>>> drivers/net/ethernet/intel/Kconfig           |   11 +++++++++++
>>>>>>>>>      drivers/net/ethernet/intel/i40e/Makefile     |    2 +-
>>>>>>>>>      drivers/net/ethernet/intel/i40e/i40e_osdep.h |    4 ++--
>>>>>>>>>      3 files changed, 14 insertions(+), 3 deletions(-)
>>>>>>>>>
>>>>>>>>> diff --git a/drivers/net/ethernet/intel/Kconfig
>>>>>>>>> b/drivers/net/ethernet/intel/Kconfig
>>>>>>>>> index 5b8300a..4d61ef5 100644
>>>>>>>>> --- a/drivers/net/ethernet/intel/Kconfig
>>>>>>>>> +++ b/drivers/net/ethernet/intel/Kconfig
>>>>>>>>> @@ -281,6 +281,17 @@ config I40E_DCB
>>>>>>>>>
>>>>>>>>>               If unsure, say N.
>>>>>>>>>
>>>>>>>>> +config I40E_FCOE
>>>>>>>>> +       bool "Fibre Channel over Ethernet (FCoE)"
>>>>>>>>> +       default n
>>>>>>>>> +       depends on I40E && DCB && FCOE
>>>>>>>>> +       ---help---
>>>>>>>>> +         Say Y here if you want to use Fibre Channel over Ethernet
>> (FCoE)
>>>>>>>>> +         in the driver. This will create new netdev for exclusive FCoE
>>>>>>>>> +         use with XL710 FCoE offloads enabled.
>>>>>>>>> +
>>>>>>>>> +         If unsure, say N.
>>>>>>>>> +
>>>>>>>>>      config I40EVF
>>>>>>>>>             tristate "Intel(R) XL710 X710 Virtual Function Ethernet
>> support"
>>>>>>>>>             depends on PCI_MSI
>>>>>>>>> diff --git a/drivers/net/ethernet/intel/i40e/Makefile
>>>>>>>>> b/drivers/net/ethernet/intel/i40e/Makefile
>>>>>>>>> index 4b94ddb..c405819 100644
>>>>>>>>> --- a/drivers/net/ethernet/intel/i40e/Makefile
>>>>>>>>> +++ b/drivers/net/ethernet/intel/i40e/Makefile
>>>>>>>>> @@ -44,4 +44,4 @@ i40e-objs := i40e_main.o \
>>>>>>>>>             i40e_virtchnl_pf.o
>>>>>>>>>
>>>>>>>>>      i40e-$(CONFIG_I40E_DCB) += i40e_dcb.o i40e_dcb_nl.o
>>>>>>>>> -i40e-$(CONFIG_FCOE:m=y) += i40e_fcoe.o
>>>>>>>>> +i40e-$(CONFIG_I40E_FCOE) += i40e_fcoe.o
>>>>>>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
>>>>>>>>> b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
>>>>>>>>> index 045b5c4..ad802dd 100644
>>>>>>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
>>>>>>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
>>>>>>>>> @@ -78,7 +78,7 @@ do {                                                            \
>>>>>>>>>      } while (0)
>>>>>>>>>
>>>>>>>>>      typedef enum i40e_status_code i40e_status; -#if
>>>>>>>>> defined(CONFIG_FCOE)
>>>>>>>>> || defined(CONFIG_FCOE_MODULE)
>>>>>>>>> +#ifdef CONFIG_I40E_FCOE
>>>>>>>>>      #define I40E_FCOE
>>>>>>>>> -#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
>>>>>>>>> +#endif
>>>>>>>>>      #endif /* _I40E_OSDEP_H_ */
>>>>>>>>>
>>>>>>>>>>> +           if (ret)
>>>>>>>>>>> +                   dev_info(&pf->pdev->dev,
>>>>>>>>>>> +                            "init_pf_fcoe failed: %d\n", ret);
>>>>>>>>>>> +   }
>>>>>>>>>>>
>>>>>>>>>>>      #endif
>>>>>>>>>>>         /* do basic switch setup */
>>>>>>>>>>> --
>>>>>>>>>>> 1.8.3.1
>>>>>>>> Thanks,
>>>>>>>> Ethan


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
