From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Mon, 03 Feb 2014 18:30:38 +0800
Message-ID: <52EF6FCE.8090704@gmail.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com>
 <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda>
 <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda>
 <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com>
 <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com>
 <20140203085855.GA26722@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B772B@AcuExch.aculab.com>
 <52EF6DCC.6040807@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "andreas.dilger@intel.com" <andreas.dilger@intel.com>,
 "jinshan.xiong@intel.com" <jinshan.xiong@intel.com>,
 Greg KH <gregkh@linuxfoundation.org>,
 "bergwolf@gmail.com" <bergwolf@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>,
 "oleg.drokin@intel.com" <oleg.drokin@intel.com>,
 David Laight <David.Laight@ACULAB.COM>,
 "jacques-charles.lafoucriere@cea.fr" <jacques-charles.lafoucriere@cea.fr>,
 Antonio Quartulli <antonio@meshcoding.com>, netdev <netdev@vger.kernel.org>,
 David Miller <davem@davemloft.net>, 'Dan Carpenter' <dan.carpenter@oracle.com>
To: James Hogan <james.hogan@imgtec.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <52EF6DCC.6040807@imgtec.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 02/03/2014 06:22 PM, James Hogan wrote:
> On 03/02/14 10:05, David Laight wrote:
>> From: Dan Carpenter
>>> On Sat, Feb 01, 2014 at 09:57:39PM +0800, Chen Gang wrote:
>>>> It seems, our kernel still stick to treate 'pack' region have effect
>>>> with both 'align' and 'sizeof'.
>>>
>>> It's not about packed regions.  It's about unions.  It's saying the
>>> sizeof() a union is a multiple of 4 unless it's packed.
>>>
>>> union foo {
>>> 	short x;
>>> 	short y;
>>> };
>>>
>>> The author intended the sizeof(union foo) to be 2 but on metag arch then
>>> it is 4.
>>
>> The same is probably be true of: struct foo { _u16 bar; };
> 
> Yes indeed.
> 
>> Architectures that define such alignment rules are a right PITA.
>> You either need to get the size to 2 without using 'packed', or
>> just not define such structures.
>> It is worth seeing if adding aligned(2) will change the size - I'm
>> not sure.
> 
> __aligned(2) alone doesn't seem to have any effect on sizeof() or
> __alignof__() unless it is accompanied by __packed. x86_64 is similar in
> that respect (it just packs sanely in the first place).
> 
> Combining __packed with __aligned(2) does the trick though (__packed
> alone sets __aligned(1) which is obviously going to be suboptimal).
> 

Oh, thank you for your explanation.

And hope this feature issue can be fixed, and satisfy both kernel and
ABI. :-)


Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
