From: f6bvp <f6bvp@free.fr>
Subject: Re: [AX25] inconsistent lock state
Date: Sat, 25 Jun 2011 17:51:39 +0200
Message-ID: <4E06040B.7040309@free.fr>
References: <4B2CD772.1030106@upmc.fr> <201106171536.15660.arnd@arndb.de> <20110617135147.GA3470@linux-mips.org> <201106171611.10655.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <201106171611.10655.arnd@arndb.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I applied the patch and since then I could not reproduce the
inconsistent lock state.
Thus mkiss patch fixed it.

Thanks,

Bernard

Le 17/06/2011 16:11, Arnd Bergmann a =E9crit :
> On Friday 17 June 2011 15:51:48 Ralf Baechle wrote:
>> On Fri, Jun 17, 2011 at 03:36:15PM +0200, Arnd Bergmann wrote:
>>
>> (Removed Jarek from cc; his email bounces.)
>>
>>> The message hints that disc_data_lock is aquired with softirqs disa=
bled,
>>> but does not itself disable softirqs, which can in rare circumstanc=
es
>>> lead to a deadlock.
>>>
>>> Does this fix it?
>> If so, drivers/net/hamradio.c, function sp_get() would probably need=
 the
>> equivalent fix.  Same for drivers/net/ppp_async.c:ap_get() and sp_ge=
t() in
>> drivers/net/ppp_synctty.c.
> It seems that ppp_synctty.c is ok, it uses write_lock_irq() already,
> sixpack.c looks like it has the same bug as mkiss. I also realized
> after sending out the patch that only the write_lock needs to be
> changed to write_lock_bh, while read_lock can leave softirqs enabled
> because it can be called recursively.
>
> 	Arnd

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
