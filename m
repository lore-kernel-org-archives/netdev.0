From: jamal <hadi@cyberus.ca>
Subject: Re: packet re-ordering on SMP machines.
Date: Sun, 25 Aug 2002 20:52:18 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208252046250.675-100000@shell.cyberus.ca>
References: <3D6922B2.1020400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D6922B2.1020400@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Sun, 25 Aug 2002, Ben Greear wrote:

> jamal wrote:
> >
> >
> >
> > NAPI fixes packet reordering problems.
>
> It does indeed.  I just patched the e1000 with the latest NAPI patch
> I could find (from Aug 15 or so), and the re-ordering problems went away.
>
> The amount of packets dropped decreased too, but I still see about 1 out of
> 1000 packets dropped due to rx-FIFO or rx-dropped.  This is when trying to run
> 60,000 pps of 1514 byte packets from one port to the other on the same dual-port e1000
> NIC (copper).  It will generate up to about 72,000 pps without dropping too many
> more...
>

That doesnt sound impressive at all. I know it's about .8 of wire rate
but you should be able to exceed that.
Robert was generating in the range of 800Kpps with that NIC if i recall
corectly

> I will do some more tests on two single-port NICs soon to see if that
> performs better.

You should see better numbers.
Also if you have SMP, tie each onto a CPU.
Additionaly get the skb recycler patch from Robert, it should improve
things even more.

>
> Also, I see the hard_start_xmit call failing 5876 times out of 2719493
> calls (for example).  The code that calls the method looks like this:
>

I dont have access to that NIC. But a stoopid question: Have you tried
increasing the transmit queue via ifconfig? 1000 packets is reasonable
for gige.

cheers,
jamal
