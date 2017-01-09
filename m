From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] intel: Use upper_32_bits and lower_32_bits
Date: Mon, 09 Jan 2017 05:33:10 -0800
Message-ID: <1483968790.2106.10.camel@perches.com>
References: <7a5cfe63cad3ef4badc30cbc2185a5bfb9250fd8.1483813334.git.joe@perches.com>
         <063D6719AE5E284EB5DD2968C1650D6DB025AC14@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB025AC14@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-01-09 at 12:55 +0000, David Laight wrote:
> From: Joe Perches
> > Sent: 07 January 2017 18:33
> > Shifting and masking various types can be made a bit
> > simpler to read by using the available kernel macros.
> 
> ...
> > -		ew32(TDBAH, (tdba >> 32));
> > -		ew32(TDBAL, (tdba & 0x00000000ffffffffULL));
> > +		ew32(TDBAH, upper_32_bits(tdba));
> > +		ew32(TDBAL, lower_32_bits(tdba));
> 
> Personally I find the original code easier to understand
> since I don't have to look up another silly macro.

It's already a pretty common usage and I believe
the naming is fairly obvious.  Also you don't have
to count the "f" characters to see how many bits
are being used.  After about 6 consecutive chars,
it can be error prone.

The leading zeros?  ugh.  The ULL too.

$ git grep -w -E "upper_32_bits|lower_32_bits" | wc -l
1569

> I'd normally not even explicitly mask the low bits
> relying on the implicit truncation of the assignment.

Relying on implicit behaviors can be noisy when
compilers complain about implicit conversions and
truncations.

> At least modern compilers aren't stupid enough to add two
> 'mask with 0xff' instructions for:
> 	*uchar_ptr = (unsigned char)(foo & 0xff);

I agree it's visual noise.
