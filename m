From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Wed, 7 Apr 2010 00:02:39 -0400
Message-ID: <70501020920527933@unknownmsgid>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain>
	<20100405091628.4890.30541.sendpatchset@localhost.localdomain>
	<20100405194356.GA10488@gospo.rdu.redhat.com>
	<4BBA9FDB.4040909@redhat.com> <4BBABAB8.4010401@redhat.com>
	<20100406144824.GB10488@gospo.rdu.redhat.com>
	<4BBBEEAA.1050100@redhat.com>
Mime-Version: 1.0 (iPhone Mail 7E18)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Neil Horman <nhorman@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matt Mackall <mpm@selenic.com>,
        "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Jeff Moyer <jmoyer@redhat.com>,
        Andy Gospodarek <gospo@redhat.com>,
        "bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <4BBBEEAA.1050100@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Apr 6, 2010, at 10:32 PM, Cong Wang <amwang@redhat.com> wrote:

> Andy Gospodarek wrote:
>> On Tue, Apr 06, 2010 at 12:38:16PM +0800, Cong Wang wrote:
>>> Cong Wang wrote:
>>>> Before I try to reproduce it, could you please try to replace
>>>> the  'read_lock()'
>>>> in slaves_support_netpoll() with 'read_lock_bh()'? (read_unlock()
>>>> too)  Try if this helps.
>>>>
>>> Confirmed. Please use the attached patch instead, for your testing.
>>>
>>> Thanks!
>>>
>> Moving those locks to bh-locks will not resolve this.  I tried that
>> yesterday and tried your new patch today without success.  That
>> warning
>> is a WARN_ON_ONCE so you need to reboot to see that it is still a
>> problem.  Simply unloading and loading the new module is not an
>> accurate
>> test.
>> Also, my system still hangs when removing the bonding module.  I do
>> not
>> think you intended to fix this with the patch, but wanted it to be
>> clear
>> to everyone on the list.
>
>
> Actually I did reboot and then tested the module. I didn't get any
> warning.
> I just tried again today, and no warnings at all.
>
> For removing bonding module, you may need another fix of mine,
> which is to fix a potential deadlock of workqueue. Try:
>
> http://lkml.org/lkml/2010/4/1/58
>
>> You should also configure your kernel with a some of the lock
>> debugging
>> enabled.  I've been using the following:
>> CONFIG_DETECT_HUNG_TASK=y
>> CONFIG_DEBUG_SPINLOCK=y
>> CONFIG_DEBUG_MUTEXES=y
>> CONFIG_DEBUG_LOCK_ALLOC=y
>> CONFIG_PROVE_LOCKING=y
>> CONFIG_LOCKDEP=y
>> CONFIG_LOCK_STAT=y
>> CONFIG_DEBUG_LOCKDEP=y
>
>
> Sure, I always keep these.
>
>> Here is the output when I remove a slave from the bond.  My
>> xmit_roundrobin patch from earlier (replacing read_lock with
>> read_trylock) was applied.  It might be helpful for you when
>> debugging
>> these issues.
>
>
> I don't apply your patch, just tested my patch.
>
>> Dead loop on virtual device bond0, fix it urgently!
>
> Please provide your bonding configuration and steps to reproduce it.
>

My first response in this thread provides the commands and
configuration needed to reproduce this.

> What I did is:
>
> 1. Load bonding module with "mode=0 miimon=100"
> 2. Enslave eth0 and active bond0
> 3. Load netconsole and send messages via bond0
> 4. Remove eth0 from bond0
> 5. Remove bonding module
> 6. Remove netconsole module

Thanks for sending your configuration.

What values are in /proc/sys/kernel/printk?

> And no deadlocks, no warnings.
>
> Thanks.
