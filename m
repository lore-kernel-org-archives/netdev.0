From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Jan 14 (lowpan, 802.15.4)
Date: Fri, 17 Jan 2014 10:49:59 -0800
Message-ID: <52D97B57.9000000@infradead.org>
References: <20140114165128.0dd51f362e0f34a2ef4dc92f@canb.auug.org.au>	<52D578A7.8020000@infradead.org> <CALT56yPzfkz7=WdT0p6EYXdsQJUT+Ld9gdd72z6_czn0YaKUWA@mail.gmail.com>
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
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CALT56yPzfkz7=WdT0p6EYXdsQJUT+Ld9gdd72z6_czn0YaKUWA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/14/2014 02:54 PM, Dmitry Eremin-Solenikov wrote:
> Hello,
> 
> 
> On Tue, Jan 14, 2014 at 9:49 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> On 01/13/2014 09:51 PM, Stephen Rothwell wrote:
>>> Hi all,
>>>
>>> This tree fails (more than usual) the powerpc allyesconfig build.
>>>
>>> Changes since 20140113:
>>>
>>
>>
>> on i386:
>>
>> net/built-in.o: In function `header_create':
>> 6lowpan.c:(.text+0x166149): undefined reference to `lowpan_header_compress'
>> net/built-in.o: In function `bt_6lowpan_recv':
>> (.text+0x166b3c): undefined reference to `lowpan_process_data'
> 
> Ah, nice Makefile hack there.
> David, Marcel, could you please consider the attached patch.
> 
> 

Hi,
I guess that the Makefile hack is still causing problems.
With today's linux-next (20140117), I see these build errors (or warnings
in the case of loadable modules):


when 802.15.4 and Bluetooth are built as loadable modules:

WARNING: net/ieee802154/6lowpan_iphc: 'lowpan_header_compress' exported twice. Previous export was in net/bluetooth/bluetooth.ko
WARNING: net/ieee802154/6lowpan_iphc: 'lowpan_process_data' exported twice. Previous export was in net/bluetooth/bluetooth.ko

when they are builtin to the kernel image:

net/ieee802154/built-in.o: In function `lowpan_header_compress':
(.text+0x3d00): multiple definition of `lowpan_header_compress'
net/bluetooth/built-in.o:(.text+0x2e8f0): first defined here
net/ieee802154/built-in.o: In function `lowpan_process_data':
(.text+0x3230): multiple definition of `lowpan_process_data'
net/bluetooth/built-in.o:(.text+0x2de20): first defined here


-- 
~Randy
