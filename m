From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] neighbour: Convert if statment in the function,
 neigh_add_timer to a WARN_ON
Date: Mon, 1 Jun 2015 20:37:21 -0700
Message-ID: <CAM_iQpXc8Sbo7UfJgfBNtv__dYnQzW29Jot+DKDHTQJ0aYqZ6A@mail.gmail.com>
References: <1433188983-23207-1-git-send-email-xerofoify@gmail.com>
	<556D16F4.3060307@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicholas Krause <xerofoify@gmail.com>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	johannes.berg@intel.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <556D16F4.3060307@miraclelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 1, 2015 at 7:37 PM, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=
=8B=B1=E6=98=8E
<hideaki.yoshifuji@miraclelinux.com> wrote:
> Nicholas Krause wrote:
>> This converts the if statement for dumping the stack into a
>> WARN_ON in order to make this function's debugging check
>> simpler and have a cleaner output when this condition
>> occurs inside this function for when bugs related to
>> adding a duplicate neighbour table timer arise.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  net/core/neighbour.c | 6 +-----
>>  1 file changed, 1 insertion(+), 5 deletions(-)
>>
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 3de6542..0bf71da 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -165,11 +165,7 @@ static int neigh_forced_gc(struct neigh_table *=
tbl)
>>  static void neigh_add_timer(struct neighbour *n, unsigned long when=
)
>>  {
>>       neigh_hold(n);
>> -     if (unlikely(mod_timer(&n->timer, when))) {
>> -             printk("NEIGH: BUG, double timer add, state is %x\n",
>> -                    n->nud_state);
>> -             dump_stack();
>> -     }
>> +     WARN_ON(unlikely(mod_timer(&n->timer, when)));
>>  }
>
> NACK, please do not use WARN_ON for things with side effects.

Just:

int ret =3D mod_timer(...);
WARN_ON(ret);
=2E..
