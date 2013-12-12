From: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent
 mac address
Date: Thu, 12 Dec 2013 22:24:18 +0200
Message-ID: <52AA1B72.1070905@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>	 <201312101814.35112@pali> <1386697762.30202.6.camel@dcbw.foobar.com>	 <201312101852.17030@pali>	 <1386796654.1516.268.camel@bwh-desktop.uk.level5networks.com>	 <52A8DA9A.50501@gmail.com>	 <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com>	 <1386802416.17188.69.camel@dcbw.foobar.com> <1386878159.1516.312.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	=?UTF-8?B?UGFsaSBSb2jDoQ==?= =?UTF-8?B?cg==?=
	<pali.rohar@gmail.com>, Kalle Valo <kvalo@adurom.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386878159.1516.312.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 12.12.2013 21:55, Ben Hutchings wrote:
> On Wed, 2013-12-11 at 16:53 -0600, Dan Williams wrote:
>> On Wed, 2013-12-11 at 22:15 +0000, Ben Hutchings wrote:
>>> On Wed, 2013-12-11 at 23:35 +0200, Ivajlo Dimitrov wrote:
>>>> On 11.12.2013 23:17, Ben Hutchings wrote:
>>>>> I think that's an even worse idea.  This is not firmware and it already
>>>>> exists in separate storage.
>>>>>
>>>>> I think that rx51_init_wl1251() in
>>>>> arch/arm/mach-omap2/board-rx51-peripherals.c should either copy the MAC
>>>>> address out of NVRAM, or if it's too early to do that, then schedule a
>>>>> function to run later and only then set up wl1251 platform data.
>>>>>
>>>>> Ben.
>>>>>
>>>> And how will that work with DT when board files will be in the history?
>>> 1. Boot loader reads the MAC address from NVRAM and puts it in the DT
>>> node.
>>> or
>>> 2. NVRAM reading is done by a tiny driver that is loaded based on the
>>> platform name and updates the DT node in memory.  (But I don't know how
>>> wl1251 should decide to defer probing if it's probed before that other
>>> driver.)
>> I'm uncomfortable with it too, and yes the permanent MAC should really
>> be known before the interface is even registered, but...
>>
>> Imagine if the MAC address for your ethernet device was stored
>> in /etc/my-mac-addr.txt, except that /etc was a read-only protected
>> partition from a very small SSD.  That's essentially the N900; it's
>> stored in a file in a normal ext2/ext3 (?) filesystem on a partition of
>> the internal flash.
> Oh, from my quick look I got the impression that this 'CAL' was stored
> directly in a specific flash partition.
>
>>    It seems like overkill to write a small driver that
>> duplicates the ext3 + MTD drivers just to read the MAC.
> [...]
>
> I don't see that anything would need to be duplicated.  But reading
> files from the kernel is really ugly, and deciding when to read the file
> would be another problem (as you noted).
>
> Ben
>
Yes, CAL is stored in /dev/mtd1, a dedicated partition in the NAND 
flash. But reading the data stored in it from the kernel is not a 
trivial task, as it uses its own pseudo-fs format etc. Not impossible (I 
RE-ed libcal a while ago [0], so there is a code that could be reused, 
calvaria works too afaik), but still doesn't sound like a very good idea.

[0] 
https://gitorious.org/community-ssu/libcal/source/d4c5fd9293ddb693c9b032b4c084cd0343b3ea26:

Ivo
