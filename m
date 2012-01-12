From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 11:03:53 +0100
Message-ID: <4F0EB009.208@broadcom.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com>
 <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net>
 <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net>
 <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net>
 <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: "Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4036 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492Ab2ALKEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 05:04:08 -0500
In-Reply-To: <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2012 08:13 AM, Linus Torvalds wrote:
> On Wed, Jan 11, 2012 at 9:30 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> The code in v3.2 also used to support srom rev < 4, the new code
>> doesn't seem to do that.
> 
> I ended up trying to bisect this, and seem to have been successful.
> The problem came in not with the BCMA use, but with commit
> 888153b3db3f ("brcm80211: smac: avoid sprom endianess conversions for
> crc8 check")

Thanks for doing that while I had put my head on a pillow.

> I haven't yet tried to revert this on top of the current tree, but I'm
> pretty sure about the bisection. That commit changes things to be read
> a byte at a time, but it *also* removes the old code that only read
> SROM_WORDS from the SROM.
> 
> Might the apple parts have different SROM contents? I assume "SROM" is
> just a serial rom, which may be external and contain things like the ?

Mostly configuration parameters for RF/PHY.

> All the BCMA changes make the revert somewhat non-trivial, could
> somebody who knows the code better please try to do it for me? It
> doesn't look complicated, and I can try to do it myself tomorrow if
> nobody else steps up, but I'd *really* prefer the guilty parties
> themselves to do it, ok?
> 
> Arend - it's your commit...

Ok. I know a hint when I see one ;-)

>                     Linus
> 

Gr. AvS
