From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
 (Hyper-V)
Date: Thu, 14 Apr 2016 17:19:24 -0700
Message-ID: <CAKgT0UckBes1tNXrNjA0R4uCdXouG9qQrf+VaLJMd8AhgYQieQ@mail.gmail.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-2-git-send-email-kys@microsoft.com>
 <5F69AC74-16B9-4EAD-8B4B-21D2EB6B3653@intel.com>
 <SN2PR03MB1919133D2E9B5DDBC2AED643A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
 <DA0F5562-FC38-4037-B018-42116DD142E8@intel.com>
 <SN2PR03MB19196E84DF934294DE7BB739A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "intel-wired-lan@linuxonhyperv.com" <intel-wired-lan@linuxonhyperv.com>,
 netdev <netdev@vger.kernel.org>, "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jackm@mellanox.com" <jackm@mellanox.com>,
 "yevgenyp@mellanox.com" <yevgenyp@mellanox.com>, "Ronciak,
 John" <john.ronciak@intel.com>, "eli@mellanox.com" <eli@mellanox.com>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "Rustad,
 Mark D" <mark.d.rustad@intel.com>, David Miller <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <SN2PR03MB19196E84DF934294DE7BB739A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 5:11 PM, KY Srinivasan <kys@microsoft.com> wrote:
>
>
>> -----Original Message-----
>> From: Rustad, Mark D [mailto:mark.d.rustad@intel.com]
>> Sent: Thursday, April 14, 2016 5:07 PM
>> To: KY Srinivasan <kys@microsoft.com>
>> Cc: David Miller <davem@davemloft.net>; netdev
>> <netdev@vger.kernel.org>; linux-kernel@vger.kernel.org;
>> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>> jasowang@redhat.com; eli@mellanox.com; jackm@mellanox.com;
>> yevgenyp@mellanox.com; Ronciak, John <john.ronciak@intel.com>; intel-
>> wired-lan@linuxonhyperv.com
>> Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
>> (Hyper-V)
>>
>> KY Srinivasan <kys@microsoft.com> wrote:
>>
>> >
>> >
>> >> -----Original Message-----
>> >> From: Rustad, Mark D [mailto:mark.d.rustad@intel.com]
>> >> Sent: Thursday, April 14, 2016 4:01 PM
>> >> To: KY Srinivasan <kys@microsoft.com>
>> >> Cc: David Miller <davem@davemloft.net>; netdev
>> >> <netdev@vger.kernel.org>; linux-kernel@vger.kernel.org;
>> >> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>> >> jasowang@redhat.com; eli@mellanox.com; jackm@mellanox.com;
>> >> yevgenyp@mellanox.com; Ronciak, John <john.ronciak@intel.com>;
>> intel-
>> >> wired-lan@linuxonhyperv.com
>> >> Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
>> >> (Hyper-V)
>> >>
>> >> Some comments below:
>> >
>> > Mark,
>> >
>> > Thank you for the comments. I will address them and repost the patches.
>> >
>> > Regards,
>> >
>> > K. Y
>>
>> Please look closely at Alex's comments. I think they are much more
>> important.
>
> I am looking at Alex's comments as I am writing this.
>

On additional thought that just occurred to me after looking over the
other patches you submitted for the hv_netvsc is that you might just
stub out the multicast, unicast, and vfta configuration calls for the
hyperV interface since all that stuff should be handled by the other
link in the bond anyway.  Then you should be able to mostly contain
all the changes other than the device IDs to the vf.c file which is
really how this kind of change should work anyway.

Also I was wondering.  Since HyperV is using a proprietary device ID
anyway do you really need the calls like the one below?:
+       if (x86_hyper == &x86_hyper_ms_hyperv) {

If we can just identify HyperV via the device Id then we could drop
the x86 arch specific bits and instead just build for all cases.

- Alex
