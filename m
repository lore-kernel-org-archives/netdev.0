From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Mon, 03 Feb 2014 18:03:17 +0800
Message-ID: <52EF6965.6040406@gmail.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com>
 <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda>
 <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda>
 <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com>
 <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com>
 <20140203085855.GA26722@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, James Hogan <james.hogan@imgtec.com>,
 andreas.dilger@intel.com, jinshan.xiong@intel.com,
 Greg KH <gregkh@linuxfoundation.org>, bergwolf@gmail.com,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-metag@vger.kernel.org, oleg.drokin@intel.com,
 jacques-charles.lafoucriere@cea.fr, Antonio Quartulli <antonio@meshcoding.com>,
 netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140203085855.GA26722@mwanda>
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

On 02/03/2014 04:58 PM, Dan Carpenter wrote:
> On Sat, Feb 01, 2014 at 09:57:39PM +0800, Chen Gang wrote:
>> It seems, our kernel still stick to treate 'pack' region have effect
>> with both 'align' and 'sizeof'.
>>
> 
> It's not about packed regions.  It's about unions.  It's saying the
> sizeof() a union is a multiple of 4 unless it's packed.
> 
> union foo {
> 	short x;
> 	short y;
> };
> 
> The author intended the sizeof(union foo) to be 2 but on metag arch then
> it is 4.
> 

Yeah, just like your original discussion.  :-)


Hmm... can we say: "for metag compiler, in a pack region, it considers
variables alignment, but does not consider about struct/union alignment
(except append packed to each related struct/union)".

For compatible (consider about its ABI), it has to keep this features,
but for kernel, it needs be changed.

So, I suggest to add one parameter to compiler to switch this feature,
and append this parameter to KBUILD_CFLAGS in "arch/metag/Makefile"
which can satisfy both ABI and kernel.


Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
