From: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 06:34:44 +1000
Message-ID: <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown> <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop> <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org> <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm> <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm> <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110729165345.GM23194-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Sent from my iPhone

On 30/07/2011, at 2:53, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:

> On Fri, Jul 29, 2011 at 12:48:36PM -0400, bfields wrote:
>> On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
>>>
>>>
>>> Sent from my iPhone
>>>
>>> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =20
>>> wrote:
>>>
>>>> Le vendredi 29 juillet 2011 =C3=A0 21:58 +1000, Greg Banks a =C3=A9=
crit :
>>>>
>>>>>
>>>>> Sure, and a whole lot of the callsites are ("..._%d", cpu), =20
>>>>> hence the
>>>>> unfortune :(
>>>>
>>>> BTW, we could name nfsd threads differently :
>>>>
>>>> Currently, they all are named : "nfsd"
>>>>
>>>> If SVC_POOL_PERCPU is selected, we could name them :
>>>> nfsd_c0 -> nfsd_cN
>>>>
>>>> If SVC_POOL_PERNODE is selected, we could name them :
>>>> nfsd_n0  -> nfsd_nN
>>>>
>>>> That would help to check with "ps aux" which cpu/nodes are under
>>>> stress.
>>>>
>>>>
>>>
>>> I like it!
>>
>> Yup, patch welcomed.--b.
>
> (Annoying fact: some initscripts stop nfsd using a rough equivalent o=
f
> "killall nfsd".  So the name of the threads is arguably ABI.  I think
> those initscripts are nuts and deserve what they get, but that may be
> because I'm forgetting the reason they do that.)
>

We had this discussion in May-June 2008; it's because the nfsds were =20
once  many many years ago userspace threads.

The "killall nfsd" semantics in those scripts are awful and lead to =20
problems shutting down when there are lots of threads. It would =20
probably be an improvement to provide a better shutdown mechanism and =20
force distros to use it.

Or, you could preserve the effective semantics by having a single =20
"nfsd" thread whose purpose is to notice that it's being signalled and =
=20
perform a clean shutdown (perhaps blocking the thread doing the kill() =
=20
call until the shutdown has completed).

Greg.--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
