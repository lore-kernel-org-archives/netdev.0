From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 03/44] Add CONFIG_HAVE_64BIT_ALIGNED_STRUCT for
 taskstats
Date: Mon, 17 Dec 2012 11:11:30 -0800 (PST)
Message-ID: <20121217.111130.2269537365220391186.davem@davemloft.net>
References: <50C5B7E3.2080909@imgtec.com>
	<CAMuHMdXpw+hWgcqDiFVdDTsFBEThjvB_Y0jcoZZHS-JGTBvYRg@mail.gmail.com>
	<50CEEB08.1080707@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, hpa@zytor.com, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de, bsingharora@gmail.com,
	mingo@kernel.org, akpm@linux-foundation.org, eparis@redhat.com,
	wad@chromium.org, james.l.morris@oracle.com, netdev@vger.kernel.org
To: james.hogan@imgtec.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <50CEEB08.1080707@imgtec.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Hogan <james.hogan@imgtec.com>
Date: Mon, 17 Dec 2012 09:51:04 +0000

> On 10/12/12 12:55, Geert Uytterhoeven wrote:
>> On Mon, Dec 10, 2012 at 11:22 AM, James Hogan <james.hogan@imgtec.com> wrote:
>>> On 08/12/12 03:43, H. Peter Anvin wrote:
>>>> On 12/05/2012 08:08 AM, James Hogan wrote:
>>>>> On 64 bit architectures with no efficient unaligned access, taskstats
>>>>> has to add some padding to a reply to prevent unaligned access warnings.
>>>>> However this also needs to apply to 32 bit architectures with 64 bit
>>>>> struct alignment such as metag (which has 64 bit memory accesses).
>>>>
>>>> Wait... 64-bit struct alignment on structures with only 32-bit members?
>>>>  That might be... interesting... in a number of places...
>>>
>>> I'll rewrite the description as it's a bit misleading. On metag 64bit
>>> struct alignment is required when it contains 64bit members, not if it
>>> only contains 32bit members. Although metag is a 32bit arch, it can do
>>> 64bit memory accesses which must be aligned.
>> 
>> The C alignment rules should take care of this automatically (struct alignment
>> is the maximum alignment of its members).
> 
> Hi Geert,
> 
> Please see the comment in mk_reply in kernel/taskstats.c. The structure
> is being serialised after 2 NLA headers and a pid which is why the extra
> padding needs to be added manually.

Please solve netlink attribute 64-bit alignment issues fundamentally
rather on a case-by-case basis.

We were just discussing this very issue on the netdev list recently,
CC:'d
