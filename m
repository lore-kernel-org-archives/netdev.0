From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Mon, 28 Feb 2005 21:35:09 -0600
Message-ID: <7bca1cb50502281935557b45cc@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
	 <db95d40c05022816301520b0a6@mail.gmail.com>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Pedro Fortuna <pedro.fortuna@gmail.com>
In-Reply-To: <db95d40c05022816301520b0a6@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> In my case, I'll need to intercept all outgoing IP packets and change
> them (including L2 frame) before they are passed to the network
> interface driver.
> The reverse operation is applied to incoming IP Packets in the destination host.
> I didnt investigate the packet_type example you provided but I hope I
> will be able to used for the purposes I explained.

If the type field of the struct packet_type you register ==
htons(ETH_P_ALL), then your packet handling function will be added to
the head of the ptype_all list.

As a result, it will see all incoming and outgoing packets - incoming
will be delivered to your function from netif_receive_skb() before the
IP/other packet handlers get to see it and outgoing packets will be
delivered from dev_queue_xmit() (which calls dev_queue_xmit_nit())
just before the packet is queued for sending by the NIC. This may work
for you.

I'm assuming all outgoing packets go through dev_queue_xmit(), though
that may not always be the case (someone more knowledgeable would have
to explain this).

Regards,

-- Asim
