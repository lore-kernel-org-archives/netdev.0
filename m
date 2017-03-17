From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 3/4] uapi glibc compat: Do not check for __USE_MISC
Date: Fri, 17 Mar 2017 19:17:52 +0100
Message-ID: <e2a5018f-46fc-003e-3632-51e356c907ea@hauke-m.de>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-4-hauke@hauke-m.de>
 <1489651152.4195.192.camel@infradead.org>
 <20170316082644.GD8672@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de
To: Mikko Rapeli <mikko.rapeli@iki.fi>,
        David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316082644.GD8672@lakka.kapsi.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/16/2017 09:26 AM, Mikko Rapeli wrote:
> On Thu, Mar 16, 2017 at 07:59:12AM +0000, David Woodhouse wrote:
>> On Sun, 2017-03-12 at 23:00 +0100, Hauke Mehrtens wrote:
>>> __USE_MISC is glibc specific and not available in musl libc. Only do
>>> this check when glibc is used. This fixes a problem with musl libc.
>>> ...
>>> -/* Coordinate with glibc net/if.h header. */
>>> -#if defined(_NET_IF_H) && defined(__USE_MISC)
>>> +/* Coordinate with libc net/if.h header. */
>>> +#if defined(_NET_IF_H) && (!defined(__GLIBC__) || defined(__USE_MISC))
>>
>> I *really* don't like building up a plethora of knowledge about
>> specific libc implementations in the kernel. As a general rule, if we
>> have *anything* that depends on __GLIBC__ then we are Doing It Wrong™.
> 
> Kernel does not depend on glibc but uapi headers check for some defintions
> so that userspace code can include both libc and kernel header files
> without compiler errors.
> 
> This interface between kernel and libc header files is messy due to long
> history of copying header files from kernel to libc implementations etc
> and thus this kind of ifdef magic with in depth knowledge of various
> libc's defintions is currently unavoidable.

I agree with you David.
Should I change my patch?

The check for __USE_MISC was added in this commit:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f0a3fdca794d1e68ae284ef4caefe681f7c18e89

musl does not define it, but still adds the defines which glibc adds
when __USE_MISC is set.

Hauke
