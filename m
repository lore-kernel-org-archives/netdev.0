From: Sam Leffler <sam@errno.com>
Subject: Re: [RFC] acx100 inclusion in mainline;
	generic 802.11 stack
Date: Mon, 6 Sep 2004 11:13:31 -0700
Sender: prism54-devel-bounces@prism54.org
Message-ID: <757AB580-0030-11D9-9224-000A95AD0668@errno.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	acx100-devel@lists.sourceforge.net, prism54-devel@prism54.org,
	jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
In-Reply-To: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Aug 31, 2004, at 11:11 AM, Denis Vlasenko wrote:

> Hi all,
>
> It looks like acx100 approaches state when we can consider it's 
> inclusion
> into mainline kernel.
>
> Some background information: acx100 and acx111 hardware is a bit like
> Atheros and possibly prism54 "softmac": it handles mostly low-level
> rx/tx stuff, leaving 802.11 stack implementation up to OS
> (which is good. To have largish potentially buggy binary-only firmware
> to cope with is a nightmare).
>
> I think what acx100 devel is working on can be best described as
> "yet another 802.11 stack implementation". This is not ok.
>
> I think we definitely need generic 802.11 stack, with individual 
> drivers
> providing only needed callbacks, just like it is done for wired eth 
> drivers.
>
> I think 'senior' network guys are in position to decide upon which
> of currently available 802.11 stacks we should continue to work.
> (Atheros has one, said to be derived from BSD, is there any others?)

To correct this oft-repeated misinformation: "Atheros has one" is 
wrong.  There is a freely available device-independent 802.11 protocol 
stack that is dual BSD/GPL licensed.  The only relationship between 
this code and Atheros is  that the madwifi project uses it to support 
Atheros hardware under Linux.  Atheros holds no copyrights on any of 
the net80211 code.

As to it being derived from BSD, that is correct but misleading.  The 
1st generation of this code was done for netbsd but the current code is 
very different and has been developed almost exclusively in Linux for 
over a year (though I'm now trying to find time to backport to 
FreeBSD).

The net80211 code is actively used in netbsd to support 6+ drivers and 
a similar number in freebsd.  There is a fairly complete implementation 
of the 802.11 protocols (fragmentation isn't there but will be soon) 
including 11g, WPA/11i, WME and WSM (coming soon).  WPA/802.11i 
supplicant support using wpa_supplicant has been available for a while 
and a hostapd-based authenticator will hit CVS shortly.  The management 
API for Linux is based on wireless extensions (WE is insufficient so 
like everyone else you'll find lots of private ioctls).

I've suggested this code as a good starting point for a "generic 802.11 
stack" but received only misinformed responses.  Folks who are unaware 
of the work should take a look at it.

	Sam
