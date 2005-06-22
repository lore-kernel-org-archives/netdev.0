From: P@draigBrady.com
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 09:42:56 +0100
Message-ID: <42B92490.40005@draigBrady.com>
References: <42A5284C.3060808@osdl.org>	<1118147904.6320.108.camel@localhost.localdomain>	<Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se> <20050621.133704.08321534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: gandalf@wlug.westbo.se, hadi@cyberus.ca, shemminger@osdl.org,
        mitch.a.williams@intel.com, john.ronciak@intel.com, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050621.133704.08321534.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Also, e1000 sends full MTU sized SKBs down into the stack even if the
> packet is very small.  This also hurts performance a lot.  As
> discussed elsewhere, it should use a "small packet" cut-off just like
> other drivers do.  If the RX frame is less than this cut-off value, a
> new smaller sized SKB is allocated and the RX data copied into it.
> The RX ring SKB is left in-place and given back to the chip.

Yes the copy is essentially free here as the data is already cached.

As a data point, I went the whole hog and used buffer recycling
in my essentially packet sniffing application. I.E. there are no
allocs per packet at all, and this make a HUGE difference. On a
2x3.4GHz 2xe1000 system I can receive 620Kpps per port sustained
into my userspace app which does a LOT of processing per packet.
Without the buffer recycling is was around 250Kpps.
Note I don't reuse an skb until the packet is copied into a
PACKET_MMAP buffer.

--=20
P=E1draig Brady - http://www.pixelbeat.org
--
