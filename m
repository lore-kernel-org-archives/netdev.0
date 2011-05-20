From: Cong Wang <amwang@redhat.com>
Subject: Re: [V2 Patch net-next-2.6] netpoll: disable netpoll when enslave
 a device
Date: Fri, 20 May 2011 11:10:26 +0800
Message-ID: <4DD5DBA2.9060302@redhat.com>
References: <20110518105558.GA3203@hmsreliant.think-freely.org> <1305794393-20775-1-git-send-email-amwang@redhat.com> <20110519113127.GE21309@gospo.rdu.redhat.com> <20110519132533.GA6729@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519132533.GA6729@shamino.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B405=E6=9C=8819=E6=97=A5 21:25, Neil Horman =E5=86=
=99=E9=81=93:
> On Thu, May 19, 2011 at 07:31:27AM -0400, Andy Gospodarek wrote:
>> On Thu, May 19, 2011 at 04:39:53PM +0800, Amerigo Wang wrote:
>> [...]
>>> diff --git a/include/linux/notifier.h b/include/linux/notifier.h
>>> index 621dfa1..3d82867 100644
>>> --- a/include/linux/notifier.h
>>> +++ b/include/linux/notifier.h
>>> @@ -211,6 +211,7 @@ static inline int notifier_to_errno(int ret)
>>>   #define NETDEV_UNREGISTER_BATCH 0x0011
>>>   #define NETDEV_BONDING_DESLAVE  0x0012
>>>   #define NETDEV_NOTIFY_PEERS	0x0013
>>> +#define NETDEV_ENSLAVE		0x0014
>>>
>>>   #define SYS_DOWN	0x0001	/* Notify of system down */
>>>   #define SYS_RESTART	SYS_DOWN
>>
>> Neil just noted the same concern I had -- the asymmetry between
>> NETDEV_ENSLAVE and NETDEV_BONDING_DESLAVE bothers me a bit.  I also
>> don't really like the followup patch that uses 'ENSLAVE' in the brid=
ging
>> code when we typically use that language for bonding only.
>>
>> What about changing NETDEV_BONDING_DESLAVE to NETDEV_RELEASE and cre=
ate
>> NETDEV_JOIN instead of NETDEV_ENSLAVE?  I would prefer that or somet=
hing
>> else that might use more generic language that could be applied to a=
ll
>> for stacked interfaces.
> JOIN and RELEASE (or perhaps LEAVE) sounds good to me.

Thanks, Andy and Neil! I will rename them to JOIN and RELEASE.
