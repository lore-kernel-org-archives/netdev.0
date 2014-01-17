From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Jan 14 (lowpan, 802.15.4)
Date: Fri, 17 Jan 2014 11:20:27 -0800
Message-ID: <52D9827B.4060401@infradead.org>
References: <20140114165128.0dd51f362e0f34a2ef4dc92f@canb.auug.org.au>	<52D578A7.8020000@infradead.org> <CALT56yPzfkz7=WdT0p6EYXdsQJUT+Ld9gdd72z6_czn0YaKUWA@mail.gmail.com> <52D980ED.6000603@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	kernel list <linux-kernel@vger.kernel.org>,
	linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: Stephen Warren <swarren@wwwdotorg.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <52D980ED.6000603@wwwdotorg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/17/2014 11:13 AM, Stephen Warren wrote:
> On 01/14/2014 03:54 PM, Dmitry Eremin-Solenikov wrote:
>> Hello,
>>
>>
>> On Tue, Jan 14, 2014 at 9:49 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
>>>
>>> On 01/13/2014 09:51 PM, Stephen Rothwell wrote:
>>>> Hi all,
>>>>
>>>> This tree fails (more than usual) the powerpc allyesconfig build.
>>>>
>>>> Changes since 20140113:
>>>>
>>>
>>>
>>> on i386:
>>>
>>> net/built-in.o: In function `header_create':
>>> 6lowpan.c:(.text+0x166149): undefined reference to `lowpan_header_compress'
>>> net/built-in.o: In function `bt_6lowpan_recv':
>>> (.text+0x166b3c): undefined reference to `lowpan_process_data'
>>
>> Ah, nice Makefile hack there.
>> David, Marcel, could you please consider the attached patch.
> 
> I think you forgot to "git add net/bluetooth/Makefile" into that patch;
> don't you need the following too (I certainly do, to build next-20140117)

Yes, that fixes the problems.

>> diff --git a/net/bluetooth/Makefile b/net/bluetooth/Makefile
>> index cc6827e2ce68..80cb215826e8 100644
>> --- a/net/bluetooth/Makefile
>> +++ b/net/bluetooth/Makefile
>> @@ -12,8 +12,4 @@ bluetooth-y := af_bluetooth.o hci_core.o hci_conn.o hci_event.o mgmt.o \
>>  	hci_sock.o hci_sysfs.o l2cap_core.o l2cap_sock.o smp.o sco.o lib.o \
>>  	a2mp.o amp.o 6lowpan.o
>>  
>> -ifeq ($(CONFIG_IEEE802154_6LOWPAN),)
>> -  bluetooth-y +=  ../ieee802154/6lowpan_iphc.o
>> -endif
>> -
>>  subdir-ccflags-y += -D__CHECK_ENDIAN__
> 
> Should I send this as a separate followup patch?
> --

I think so.  It was not part of the posted patch.

Thanks.

-- 
~Randy
