From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: make allyesconfig i386 build failure with next-20150122 (caused
 by fb_agm1264k-fl driver)
Date: Tue, 27 Jan 2015 14:04:32 +0100
Message-ID: <54C78CE0.6040207@imap.cc>
References: <CA+r1ZhhXF+hicy7JKo3jAbgSbO4KOLm6BwPosTKNb+E_Cb4yPQ@mail.gmail.com> <20150126215959.GA9853@roeck-us.net> <20150126224654.GA17166@kroah.com> <54C6FB28.3000304@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	devel <devel@driverdev.osuosl.org>, isdn@linux-pingi.de,
	netdev <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <54C6FB28.3000304@roeck-us.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 27.01.2015 um 03:42 schrieb Guenter Roeck:
> On 01/26/2015 02:46 PM, Greg Kroah-Hartman wrote:
>> On Mon, Jan 26, 2015 at 01:59:59PM -0800, Guenter Roeck wrote:
>>> On Thu, Jan 22, 2015 at 12:10:33PM -0700, Jim Davis wrote:
>>>> make ARCH=i386 allyesconfig fails with
>>>>
>>>> drivers/staging/built-in.o: In function `reset':
>>>> (.text+0x2ae89d): multiple definition of `reset'
>>>> drivers/isdn/built-in.o:(.text+0x185dc2): first defined here
>>>> make[1]: *** [drivers/built-in.o] Error 1
>>>
>>> Culprit:
>>>
>>> commit b2ebd4be6fa1d2329b63531b044f9e25474981cb
>>> Author: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>>> Date:   Wed Dec 31 10:11:10 2014 +0100
>>>
>>>      staging: fbtft: add fb_agm1264k-fl driver
>>>
>>> A global function named 'reset' isn't really a good idea.
>>>
>>> Not that the global function with the same name in the isdn code
>>> is better ;-).
>>
>> Agreed, the fbtft code is now fixed.  Patches to fix the isdn code would
>> be gladly accepted as well :)
>>
> 
> Did you have a look into the isdn code ? It will need someone
> with a lot of spare time to clean this code up.

Cleaning up the entire isdn code certainly will, but that particular
problem is in fact much more limited. The function in question is
declared, along with several other also much too generically named
ones, in drivers/isdn/sc/card.h which is included nowhere outside
drivers/isdn/sc. So these are really private functions of the
SpellCaster driver which could easily be renamed.

OTOH good old SpellCaster was an ISA card, and the sc driver depends
on the deprecated I4L framework. I wonder if it's worth any effort.

Tilman
