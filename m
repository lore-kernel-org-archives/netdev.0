From: Zhu Yanhai <zhu.yanhai@gmail.com>
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
Date: Fri, 26 Aug 2011 11:30:35 +0800
Message-ID: <CAC8teKXqZktBK7+GbLgHn-2k+zjjf8uieRM_q_V7JK7ePAk9Lg@mail.gmail.com>
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
 <4E54BDCF.9020504@profihost.ag> <20110824093336.GB5214@localhost>
 <4E560F2A.1030801@profihost.ag> <20110826021648.GA19529@localhost>
 <4E570AEB.1040703@profihost.ag> <20110826030313.GA24058@localhost>
 <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag> <20110826032601.GA26282@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stefan Priebe <s.priebe@profihost.ag>, Pekka Enberg <penberg@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>,
	Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110826032601.GA26282@localhost>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Fengguang,
Maybe it's because zone_reclaim_mode? We often have received some reports t=
hat
scp or something like that is slow with no reason, and mostly it's due
to someone
enabled zone_reclaim_mode by mistake.

Stefan, is your zone_reclaim_mode enabled? try 'cat
/proc/sys/vm/zone_reclaim_mode',
and echo 0 to it to disable.

Thanks,
Zhu Yanhai

2011/8/26 Wu Fengguang <fengguang.wu@intel.com>:
> On Fri, Aug 26, 2011 at 11:13:07AM +0800, Stefan Priebe wrote:
>>
>> >> There is at least a numastat proc file.
>> >
>> > Thanks. This shows that node0 is accessed 10x more than node1.
>>
>> What can i do to prevent this or isn't this normal when a machine mostly=
 idles so processes are mostly processed by cpu0.
>
> Yes, that's normal. However it should explain why it's slow even when
> there are lots of free pages _globally_.
>
>> >
>> >> complete ps output:
>> >> http://pastebin.com/raw.php?i=3Db948svzN
>> >
>> > In that log, scp happens to be in R state and also no other tasks in D
>> > state. Would you retry in the hope of catching some stucked state?
>> Sadly not as the sysrq trigger has rebootet the machine and it will now =
run fine for 1 or 2 days.
>
> Oops, sorry! It might be possible to reproduce the issue by manually
> eating all of the memory with sparse file data:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0truncate -s 1T 1T
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cp 1T /dev/null
>
>> >
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 echo t> =C2=A0/proc/sysrq-trigger
>> >> sadly i wa sonly able to grab the output in this crazy format:
>> >> http://pastebin.com/raw.php?i=3DMBXvvyH1
>> >
>> > It's pretty readable dmesg, except that the data is incomplete and
>> > there are nothing valuable in the uploaded portion..
>> That was everything i could grab through netconsole. Is there a better w=
ay?
>
> netconsole is enough. =C2=A0The partial output should be due to the reboo=
t...
>
> Thanks,
> Fengguang
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
