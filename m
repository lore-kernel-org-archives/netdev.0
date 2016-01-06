From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict
 synchronization of link_up and speed
Date: Wed, 6 Jan 2016 13:41:39 +0800
Message-ID: <568CA913.3030901@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
	<1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
	<1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
	<5683462C.3020801@gmail.com>
	<87618083B2453E4A8714035B62D67992504FD7FB@FMSMSX105.amr.corp.intel.com>
	<568393C6.1060105@gmail.com>
	<87618083B2453E4A8714035B62D67992504FD8D5@FMSMSX105.amr.corp.intel.com>
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
In-Reply-To: <87618083B2453E4A8714035B62D67992504FD8D5@FMSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/31/2015 12:37 AM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>> Sent: Wednesday, December 30, 2015 12:20 AM
>> To: Tantilov, Emil S; Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson,
>> Shannon; Wyborny, Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak,
>> John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org;
>> netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>> Vincent (Wind River)
>> Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization
>> of link_up and speed
>>
>> On 12/30/2015 02:55 PM, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>>>> Sent: Tuesday, December 29, 2015 6:49 PM
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
>>>> On 12/30/2015 12:18 AM, Tantilov, Emil S wrote:
>>>>>> -----Original Message-----
>>>>>> From: Intel-wired-lan [mailto:intel-wired-lan-
>> bounces@lists.osuosl.org]
>>>> On
>>>>>> Behalf Of zyjzyj2000@gmail.com
>>>>>> Sent: Monday, December 28, 2015 6:32 PM
>>>>>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>>>>>> Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John; Williams,
>>>> Mitch
>>>>>> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>>>>>> devel@lists.sourceforge.net
>>>>>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River);
>>>> Bourg,
>>>>>> Vincent (Wind River)
>>>>>> Subject: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization
>>>> of
>>>>>> link_up and speed
>>>>>>
>>>>>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>>>>>
>>>>>> When the X540 NIC acts as a slave of some virtual NICs, it is very
>>>>>> important to synchronize link_up and link_speed, such as a bonding
>>>>>> driver in 802.3ad mode. When X540 NIC acts as an independent
>> interface,
>>>>>> it is not necessary to synchronize link_up and link_speed. That is,
>>>>>> the time span between link_up and link_speed is acceptable.
>>>>> What exactly do you mean by "time span between link_up and link_speed"?
>>>> In the previous mail, I show you some ethtool logs. In these logs, there
>>>> is some
>>>> time with NIC up while speed is unknown. I think this "some time" is
>>>> time span between
>>>> link_up and link_speed. Please see the previous mail for details.
>>> Was this when reporting the link state from check_link() (reading the
>> LINKS
>>> register) or reporting the adapter->link_speed?
>>>
>>>>> Where is it you think the de-synchronization occurs?
>>>> When a NIC interface acts as a slave, a flag "IFF_SLAVE" is set in
>>>> netdevice struct.
>>>> Before we enter this function, we check IFF_SLAVE flag. If this flag is
>>>> set, we continue to check
>>>> link_speed. If not, this function is executed whether this link_speed is
>>>> unknown or not.
>>> I can already see this in your patch. I was asking about the reason why
>>> your change is needed.
>> an extreme example, let us assume this scenario:
> Is this the scenario you are trying to fix?
Sure. If IFF_SLAVE is checked, this scenario will not happen.

Zhu Yanjun
>
>> An ixgbe NIC directly connects to another NIC (let us call it NIC-a).
>> And auto-negotiate is off while no static speed is set in the 2 NICs.
> The ixgbe driver does not support disabling auto-negotiation directly.
> The only time this is true is when the advertised speed is restricted,
> so the above scenario is not possible (you either have autoneg or
> advertised speed set) with the current driver.
>
> Is this example in theory or do you have your interface configured this
> way somehow?
>
> Thanks,
> Emil
>
>


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
