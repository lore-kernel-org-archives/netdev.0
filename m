From: P@draigBrady.com
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 09:56:30 +0100
Message-ID: <42BA793E.4080008@draigBrady.com>
References: <42A5284C.3060808@osdl.org>	 <1118147904.6320.108.camel@localhost.localdomain>	 <Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>	 <20050621.133704.08321534.davem@davemloft.net>	 <42B92490.40005@draigBrady.com> <1119469066.6918.168.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, gandalf@wlug.westbo.se,
        shemminger@osdl.org, mitch.a.williams@intel.com,
        john.ronciak@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1119469066.6918.168.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2005-22-06 at 09:42 +0100, P@draigBrady.com wrote:
>=20
>=20
>>Yes the copy is essentially free here as the data is already cached.
>>
>>As a data point, I went the whole hog and used buffer recycling
>>in my essentially packet sniffing application. I.E. there are no
>>allocs per packet at all, and this make a HUGE difference. On a
>>2x3.4GHz 2xe1000 system I can receive 620Kpps per port sustained
>>into my userspace app which does a LOT of processing per packet.
>>Without the buffer recycling is was around 250Kpps.
>>Note I don't reuse an skb until the packet is copied into a
>>PACKET_MMAP buffer.
>=20
>=20
> Was this machine SMP?

Yes. 2 x 3.4GHz P4s
1 logical CPU per port (irq affinity)
1 thread (NB on same logical CPU as irq (sched_affinity))
to do user space per packet processing.

> NAPI involved?

Yep.

> I take it nothing interfering in
> the middle with the headers?

It uses the standard path to PACKET_MMAP buffer
e1000_clean_rx_irq -> netif_receive_skb -> tpacket_rcv

P=E1draig.
