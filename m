From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] dsa: b53: fix big-endian register access
Date: Thu, 16 Jun 2016 10:57:05 -0700
Message-ID: <5762E871.9030702@gmail.com>
References: <20160616090017.912604-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616090017.912604-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2016 02:00 AM, Arnd Bergmann wrote:
> The b53 dsa register access confusingly uses __raw register accessors
> when both the CPU and the device are big-endian, but it uses little-
> endian accessors when the same device is used from a little-endian
> CPU, which makes no sense.
> 
> This uses normal accessors in device-endianess all the time, which
> will work in all four combinations of register and CPU endianess,
> and it will have the same barrier semantics in all cases.
> 
> This also seems to take care of a (false positive) warning I'm getting:
> 
> drivers/net/dsa/b53/b53_mmap.c: In function 'b53_mmap_read64':
> drivers/net/dsa/b53/b53_mmap.c:109:10: error: 'hi' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>   *val = ((u64)hi << 32) | lo;
> 
> I originally planned to submit another patch for that warning
> and did this one as a preparation cleanup, but it does seem to be
> sufficient by itself.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
