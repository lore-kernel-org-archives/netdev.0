From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization of
 link_up and speed
Date: Thu, 7 Jan 2016 10:38:47 +0800
Message-ID: <568DCFB7.7020307@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
 <87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
 <5683462C.3020801@gmail.com>
 <87618083B2453E4A8714035B62D67992504FD7FB@FMSMSX105.amr.corp.intel.com>
 <568393C6.1060105@gmail.com>
 <87618083B2453E4A8714035B62D67992504FD8D5@FMSMSX105.amr.corp.intel.com>
 <568CA913.3030901@gmail.com>
 <87618083B2453E4A8714035B62D6799250503F00@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
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
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35611 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbcAGCjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 21:39:00 -0500
Received: by mail-io0-f174.google.com with SMTP id 77so207261430ioc.2
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 18:39:00 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D6799250503F00@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2016 11:30 PM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>> Sent: Tuesday, January 05, 2016 9:42 PM
>> To: Tantilov, Emil S; Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson,
>> Shannon; Wyborny, Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak,
>> John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org;
>> netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>> Vincent (Wind River)
>> Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization
>> of link_up and speed
>>
>> On 12/31/2015 12:37 AM, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>>>> Sent: Wednesday, December 30, 2015 12:20 AM
>>>> To: Tantilov, Emil S; Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson,
>>>> Shannon; Wyborny, Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak,
>>>> John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org;
>>>> netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>>>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River);
>> Bourg,
>>>> Vincent (Wind River)
>>>> Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict
>> synchronization
>>>> of link_up and speed
>>>>
>>>> On 12/30/2015 02:55 PM, Tantilov, Emil S wrote:
>>>>>> -----Original Message-----
>>>>>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>>>>>> Sent: Tuesday, December 29, 2015 6:49 PM
>>>>>> To: Tantilov, Emil S; Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson,
>>>>>> Shannon; Wyborny, Carolyn; Skidmore, Donald C; Allan, Bruce W;
>> Ronciak,
>>>>>> John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org;
>>>>>> netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>>>>>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River);
>>>> Bourg,
>>>>>> Vincent (Wind River)
>>>>>> Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict
>>>> synchronization
>>>>>> of link_up and speed
>>>>>>
>>>>>> On 12/30/2015 12:18 AM, Tantilov, Emil S wrote:
>>>>>>>> -----Original Message-----
>>>>>>>> From: Intel-wired-lan [mailto:intel-wired-lan-
>>>> bounces@lists.osuosl.org]
>>>>>> On
>>>>>>>> Behalf Of zyjzyj2000@gmail.com
>>>>>>>> Sent: Monday, December 28, 2015 6:32 PM
>>>>>>>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>>>>>>>> Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John;
>> Williams,
>>>>>> Mitch
>>>>>>>> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>>>>>>>> devel@lists.sourceforge.net
>>>>>>>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River);
>>>>>> Bourg,
>>>>>>>> Vincent (Wind River)
>>>>>>>> Subject: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict
>> synchronization
>>>>>> of
>>>>>>>> link_up and speed
>>>>>>>>
>>>>>>>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>>>>>>>
>>>>>>>> When the X540 NIC acts as a slave of some virtual NICs, it is very
>>>>>>>> important to synchronize link_up and link_speed, such as a bonding
>>>>>>>> driver in 802.3ad mode. When X540 NIC acts as an independent
>>>> interface,
>>>>>>>> it is not necessary to synchronize link_up and link_speed. That is,
>>>>>>>> the time span between link_up and link_speed is acceptable.
>>>>>>> What exactly do you mean by "time span between link_up and
>> link_speed"?
>>>>>> In the previous mail, I show you some ethtool logs. In these logs,
>> there
>>>>>> is some
>>>>>> time with NIC up while speed is unknown. I think this "some time" is
>>>>>> time span between
>>>>>> link_up and link_speed. Please see the previous mail for details.
>>>>> Was this when reporting the link state from check_link() (reading the
>>>> LINKS
>>>>> register) or reporting the adapter->link_speed?
>>>>>
>>>>>>> Where is it you think the de-synchronization occurs?
>>>>>> When a NIC interface acts as a slave, a flag "IFF_SLAVE" is set in
>>>>>> netdevice struct.
>>>>>> Before we enter this function, we check IFF_SLAVE flag. If this flag
>> is
>>>>>> set, we continue to check
>>>>>> link_speed. If not, this function is executed whether this link_speed
>> is
>>>>>> unknown or not.
>>>>> I can already see this in your patch. I was asking about the reason why
>>>>> your change is needed.
>>>> an extreme example, let us assume this scenario:
>>> Is this the scenario you are trying to fix?
>> Sure. If IFF_SLAVE is checked, this scenario will not happen.
> I already explained why this is not a valid scenario, but if you were able
> to set it up somehow I'd like to know how you did it
Sorry. Why can we not disable auto-negotiate on ixgbe NIC ? To be 
honest, I am interested in it.
This is related with hardware or driver?

Thanks a lot.
Zhu Yanjun
>
> If we are to enter ixgbe_watchdog_link_is_up() with unknown link this would
> be an issue regardless of whether the interface is a part of a bond or not,
> but you haven't provided any proof that this is the case. Do you have a
> dmesg log that shows ixgbe reporting unknown speed?
>
> Was your patch tested by the customer that reported this issue?
>
> Thanks,
> Emil
>
>
