From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 11:27:24 +0100
Message-ID: <47397C0C.4060106@cosmosbay.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>	 <20071112174759.c2777ea2.dada1@cosmosbay.com> <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: Antoine Zen-Ruffinen <antoine.zen@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Antoine Zen-Ruffinen a =E9crit :
> What does it bring me to have a nanosecond precision if it is not
> related to the actual arrival of frame time ? As it seem I can feel
> skb->tstamp with whatever I want, I always become something else usin=
g
> ioctl(). (I'm using kernel 2.6.23).
>
>  =20
I guess you misunderstood kernel source, because it is related to=20
arrival time, more exactly when it was processed by network stack.
(Beware  modern NICS can delay the rx interrupt by some us (ethtool -c=20
eth0), so that an interrupt can feed more than one packet to the OS)

Check net/core/dev.c function netif_rx()

{
=2E..
   if (!skb->tstamp.tv64)
       net_timestamp(skb);

}

So as soon your system as at least one socket 'asking for tsamps',=20
netstamp_needed is not null, and net_timestamp() will call __net_timest=
amp()
wich does :

skb->tstamp =3D ktime_get_real();

So you should not 'feed' tstamp.tv64 and let it being 0, so that=20
netif_rx() can do its job.





