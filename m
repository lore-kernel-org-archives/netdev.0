From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (126)
Date: Thu, 31 Mar 2005 22:00:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0503312156220.7391@bizon.gios.gov.pl>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
 <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au>
 <20050329114926.GA14986@elte.hu> <20050330082640.GA8269@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-995482138-1112299205=:7391"
Cc: Ingo Molnar <mingo@elte.hu>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330082640.GA8269@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-995482138-1112299205=:7391
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 30 Mar 2005, Herbert Xu wrote:

> On Tue, Mar 29, 2005 at 01:49:26PM +0200, Ingo Molnar wrote:
>>
>> (i guess the debug message should be extended to do a dump_stack() so
>> that we see which process does?)
>
> Never mind.  I think I've found what it is.  The only thing I can't
> figure out is why we're only seeing it now when this bug has been
> around since day one.
>
> In netlink_dump we're operating on sk after dropping the cb lock.
> This is racy because the owner of the socket could close it after
> we drop the cb lock.
>
> This is possible because netlink_dump isn't always called from the
> context of the process that owns the socket.  For instance, if there
> is contention on rtnl then rtnetlink requests will be processed by
> the process that owns the rtnl.
>
> The solution is to hold a ref count on the socket before we drop
> the cb lock.

OK. I'm no longer able to trigger this error. And the patch is=20
already in the linux-2.6 repository. Thank you.

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-995482138-1112299205=:7391--
