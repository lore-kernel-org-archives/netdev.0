From: yalin wang <yalin.wang2010@gmail.com>
Subject: Re: [RFC] bmac:change to use bitrev8() generic function
Date: Tue, 11 Aug 2015 10:06:23 +0800
Message-ID: <89DC2B55-8B16-4B35-8EE0-AAD912E273BA@gmail.com>
References: <9A81C947-6F69-4549-B1D0-58061D6976CE@gmail.com> <20150810114901.GS16878@distanz.ch> <063D6719AE5E284EB5DD2968C1650D6D1CB77DC9@AcuExch.aculab.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Tobias Klauser <tklauser@distanz.ch>,
	"fabf@skynet.be" <fabf@skynet.be>,
	"david@gibson.dropbear.id.au" <david@gibson.dropbear.id.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB77DC9@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Aug 10, 2015, at 20:02, David Laight <David.Laight@ACULAB.COM> wrote:
> 
>> From: Tobias Klauser
>> Sent: 10 August 2015 12:49
>> On 2015-08-10 at 11:53:41 +0200, yalin wang <yalin.wang2010@gmail.com> wrote:
>>> This change to use generic bitrev8() for bmac driver.
> ...
>>> @@ -871,7 +860,7 @@ bmac_addhash(struct bmac_data *bp, unsigned char *addr)
>>> 
>>> 	if (!(*addr)) return;
>>> 	crc = bmac_crc((unsigned short *)addr) & 0x3f; /* Big-endian alert! */
> 
> Why not *((u8 *)addr + 1) & 0x3f
> 
>>> -	crc = reverse6[crc];	/* Hyperfast bit-reversing algorithm */
>>> +	crc = bitrev8((u8)crc);
>> 
>> No, this won't work. reverse6 works on 6 bit values, while bitrev8 works
>> on 8bit values, e.g. reverse6[1] = 0x20, while bitrev8(1) = 0x80
> 
> You could use bitrev8(n) >> 2.
> 
> But that is a 'strange' map of a 7-bit value to a 6-bit one.
> 
> I thought it was more common for ethernet hardware to use the
> value of the crc register after all 6 bytes of the mac address
> had been processed.
oh, my mistake, i will change it in V2 for review.