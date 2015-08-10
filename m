From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC] bmac:change to use bitrev8() generic function
Date: Mon, 10 Aug 2015 12:02:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB77DC9@AcuExch.aculab.com>
References: <9A81C947-6F69-4549-B1D0-58061D6976CE@gmail.com>
 <20150810114901.GS16878@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "fabf@skynet.be" <fabf@skynet.be>,
	"david@gibson.dropbear.id.au" <david@gibson.dropbear.id.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: 'Tobias Klauser' <tklauser@distanz.ch>,
	yalin wang <yalin.wang2010@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810114901.GS16878@distanz.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Tobias Klauser
> Sent: 10 August 2015 12:49
> On 2015-08-10 at 11:53:41 +0200, yalin wang <yalin.wang2010@gmail.com> wrote:
> > This change to use generic bitrev8() for bmac driver.
...
> > @@ -871,7 +860,7 @@ bmac_addhash(struct bmac_data *bp, unsigned char *addr)
> >
> >  	if (!(*addr)) return;
> >  	crc = bmac_crc((unsigned short *)addr) & 0x3f; /* Big-endian alert! */

Why not *((u8 *)addr + 1) & 0x3f

> > -	crc = reverse6[crc];	/* Hyperfast bit-reversing algorithm */
> > +	crc = bitrev8((u8)crc);
> 
> No, this won't work. reverse6 works on 6 bit values, while bitrev8 works
> on 8bit values, e.g. reverse6[1] = 0x20, while bitrev8(1) = 0x80

You could use bitrev8(n) >> 2.

But that is a 'strange' map of a 7-bit value to a 6-bit one.

I thought it was more common for ethernet hardware to use the
value of the crc register after all 6 bytes of the mac address
had been processed.

	David
