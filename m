From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 07:23:42 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040815112342.GT2050@ruslug.rutgers.edu>
References: <200408150118.30598.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acx100-devel@lists.sourceforge.net, prism54-devel@prism54.org,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>, Netdev <netdev@oss.sgi.com>
Return-path: <prism54-devel-bounces@prism54.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200408150118.30598.vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


[Included Jeff/Netdev on the thread]

Jeff,

can you review Denis's proposed idea and comment on it? 
Comments from others are welcomed. I ask since we need to decide if we
want this in our cvs repository soon or not. It won't make sense to
commit the work unless it will eventually be accepted by you.

Denis, to not loose your work or get it out of sync with our cvs
repository please set up a branch for yourself and commit there. That
way if it gets approved all you have to do is merge. Maybe now would be
a good time to set up subversion for our project...

	Luis

On Sun, Aug 15, 2004 at 01:18:30AM +0300, Denis Vlasenko wrote:
> Hi all,
> 
> This patch adds new private ioctl:
> 
> iwpriv <iface> set_rate "1,2,5,11 11p,24d"
> 
> Similar ioctl is already added to acx100 driver.
> With these ioctl, I managed to connect acx100
> STA to prism54 AP using only ofdm modulation.
> 
> Syntax: two space delimited lists.
> First one defines basic rate set, second one
> lists additional usable rates and is optional.
> 
> Syntax of lists: comma separated list of
> rates in Mbit/s, rounded down to integer value
> (translation: 5 == 5.5Mbit/s), optionally suffixed
> by modulation. Currently valid suffixes are:
> c: cck
> d: cckofdm
> o: ofdm
> p: pbcc
> more will be added as new standards emerge.
> 
> When suffix is omitted, it defaults to "natural" modulation
> for given rate. Here are default and currently
> allowed alternative modulations, default is listed first:
> 1,2:(no suffixes allowed)
> 5:cck pbcc
> 11:cck pbcc
> 22:pbcc
> 33:pbcc
> other rates:ofdm
> 
> Driver will refuse ioctl if it cannot satisfy it precisely.
> 
> Examples:
> 
> iwpriv wlan0 set_rate 11
> ? ? fixed rate, 11Mbit/s (cck) basic rate
> iwpriv wlan0 set_rate 22
> ? ? fixed rate, 22Mbit/s (pbcc) basic rate
> iwpriv wlan0 set_rate 5,11
> ? ? auto rate, both 5.5 and 11Mbit/s (cck) are basic rates
> iwpriv wlan0 set_rate "5 11,22"
> ? ? auto rate, 5.5 is basic rate, 11 (cck) and 22(pbcc) extended rates
> iwpriv wlan0 set_rate "5 11p,22"
> ? ? auto rate, 5.5 is basic rate, 11 (pbcc) and 22(pbcc) extended rates
> iwpriv wlan0 set_rate "1,2,5,11 6,9,12,18,24,36,48,54"
> ? ? auto rate, 1,2,5.5,11 are basic, everything else
> ? ? are extended rates, using ofdm
> iwpriv wlan0 set_rate "6 9,12,18,24,36,48,54"
> ? ? 6 (ofdm) basic rate, 9,12,18,24,36,48,54 (ofdm) extended
> ? ? it is an '11g-only' setup: use only 11g-rates with ofdm,
> ? ? will interfere with 11b equipment
> iwpriv wlan0 set_rate "6d 9d,12d,18d,24d,36d,48d,54d"
> ? ? 6 (cckofdm) basic rate, g-rates (cckofdm) extended
> ? ? '11g 11b-compatible' setup: use only g-rates with cckofdm,
> ? ? 11b stations in the area can detect signal and avoid collisions
> ? ? (am I right here?)
> 
> Notes:
> * ioctl takes ASCIIZ string as a parameter. This is intentional.
>   I think that in this case, ASCII format is more flexible and future-proof
>   than binary, while not being too hard to parse.
> * setrates.c (contains parser) compiles down to 1k of code+data.
>   Jean, do you see any problems with moving it into wireless.c in the future?
> * whitespace is made consistent with rest of the driver
> * leak fixed
> * rate settings will survive reset now
> 
> Comments?
> --
> vda



-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
