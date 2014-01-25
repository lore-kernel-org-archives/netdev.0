From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Sat, 25 Jan 2014 19:55:46 +0800
Message-ID: <52E3A642.7010307@gmail.com>
References: <52DA4E6A.1000308@gmail.com> <20140118100547.GS7444@mwanda>
 <52DA56C2.5010802@gmail.com> <20140118142404.GT7444@mwanda>
 <52DBA3D4.3090308@gmail.com> <52DD0EFF.2010305@imgtec.com>
 <20140120123045.GV7444@mwanda> <52DD18A5.1090308@imgtec.com>
 <20140120125603.GD4815@mwanda> <20140120211356.GG4815@mwanda>
 <52DE4DA3.7090301@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, andreas.dilger@intel.com,
 Antonio Quartulli <antonio@meshcoding.com>,
 Greg KH <gregkh@linuxfoundation.org>, bergwolf@gmail.com,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>, oleg.drokin@intel.com,
 jacques-charles.lafoucriere@cea.fr, jinshan.xiong@intel.com,
 netdev <netdev@vger.kernel.org>, linux-metag@vger.kernel.org,
 Dan Carpenter <dan.carpenter@oracle.com>
To: James Hogan <james.hogan@imgtec.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <52DE4DA3.7090301@imgtec.com>
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

On 01/21/2014 06:36 PM, James Hogan wrote:
> Hi Dan,
> 
> On 20/01/14 21:13, Dan Carpenter wrote:
>> I made a quick and dirty sparse patch to check for this.  I don't think
>> I will bother trying to send it to sparse upstream, but you can if you
>> want to.
>>
>> It found 289 unions which might need a __packed added.  The lustre
>> unions were not in my allmodconfig so they're not listed.
> 
> Thanks a lot for this, it seems to be useful. I'm adapting it to reduce
> false negatives (e.g. omitting the check if the struct/union is already
> packed), and I imagine it could be made to only warn about padded
> unpacked structs/unions which are used as nested members of packed
> structs/unions. It wouldn't catch everything but would probably catch a
> lot of cases that are most likely to be genuine since they would have
> been packed at the outer level for a reason.
> 
>> Perhaps there could be a command line option or a pragma so that unions
>> will work in the kernel.  We don't care about linking to outside
>> libraries.
> 
> We still interact with userland via structs and unions, so it would
> probably have to exclude anything in uapi/.
> 

Thank all of you firstly.

But excuse me, I am still not quit clear that: "what need we do enough
to solve this feature issue?"

So I guess our current result is:

 - It is not a good idea to only let kernel to fit with compiler.

 - It is not a good idea to only let compiler to fit with kernel.

 - Need let compiler and kernel to fit with each other:

   - compiler will print related warning, but not break compiling.
     so metag compiler need be improvement (check and warn for it).

   - if check alignment explicitly in kernel source code, it need be
     fixed within kernel: "apply related patches (pack each struct or
     union), but the related patch comments need be improved".

Is what I guess correct?

Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
