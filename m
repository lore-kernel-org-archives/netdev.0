From: David Miller <davem@davemloft.net>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Wed, 07 Dec 2016 19:37:16 -0500 (EST)
Message-ID: <20161207.193716.50344961208535056.davem@davemloft.net>
References: <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
        <20161207.145240.1636297838792223189.davem@davemloft.net>
        <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, netdev@vger.kernel.org,
        linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
        wireguard@lists.zx2c4.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 8 Dec 2016 01:29:42 +0100

> On Wed, Dec 7, 2016 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
>> The only truly difficult case to handle is GRE encapsulation.  Is
>> that the situation you are running into?
>>
>> If not, please figure out what the header configuration looks like
>> in the case that hits for you, and what the originating device is
>> just in case it is a device driver issue.
> 
> My case is my own driver and my own protocol, which uses a 13 byte
> header. I can, if absolutely necessary, change the protocol to add
> another byte of padding. Or I can choose not to decrypt in place but
> rather use a different trick, like overwriting the header during
> decryption, though this removes some of the scatterwalk optimizations
> when src and dst are the same. Or something else. I wrote the top
> email of this thread inquiring about just exactly how bad it is to
> call netif_rx(skb) when skb->data is unaligned.

You really have to land the IP header on a proper 4 byte boundary.

I would suggest pushing 3 dummy garbage bytes of padding at the front
or the end of your header.
