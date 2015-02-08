From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: Kill I4L?
Date: Mon, 09 Feb 2015 00:59:58 +0100
Message-ID: <54D7F87E.4050506@linux-pingi.de>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>	 <1423328797-17865-3-git-send-email-baspeters93@gmail.com>	 <54D650BF.5000400@cogentembedded.com> <1423336761.2933.7.camel@perches.com> <1423341800.2246.68.camel@x220> <54D7BD4A.4090101@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, Paul Bolle <pebolle@tiscali.nl>,
	Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D7BD4A.4090101@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 08.02.2015 um 20:47 schrieb Tilman Schmidt:
> Am 07.02.2015 um 21:43 schrieb Paul Bolle:
>> On Sat, 2015-02-07 at 11:19 -0800, Joe Perches wrote:
>>> Does anyone still use these cards?
> 
>> 0) Good question.
> 
> I very much doubt it. It was an ISA card, not even PnP. I'd imagine
> any systems of that kind would be retired by now.
> 

Agreed in general, but I know people still running such ISA based
machines - mostly PC in industrial environments with ISDN uplinks for
service and maintenance.
And I4L is also used in some vending machines for card authorization so
far I know.
They usually using old kernels (<3.0) so they are not directly affected
if this will be removed.

>> 2) Broader picture: if I remember correctly there are now four
>> different flavors of ISDN in the kernel: - really old: pre-i4l
> 
> I don't think any traces of that are still present in current kernel
> releases. It should all have been left behind on the switch to 2.6.
> 

Yes.

>> - very old: i4l - just old: CAPI - not so old: mISDN
> 
> Those are the in-tree ones. To make matters worse, the Asterisk people
> invented three more (Zaptel, DAHDI and vISDN) which are maintained
> out-of-tree. Apparently they weren't satisfied with any the in-tree
> ones and didn't feel like helping to improve one of them to match
> their needs.
> 
>> [snip] So the current ISDN situation is a bit messy.
> 
> That's putting it mildly.
> 
>> Tilman might be able to provide a clearer, and maybe less grumpy, 
>> summary of the current situation.
> 
> Don't know about either. ;-)
> 
>> [M]aybe we should consider, say, removing i4l and pre i4l and see
>> who complains. That might be a rude thing to do. So perhaps the 
>> various ISDN flavors should be left alone until ... what exactly?
> 
> I'd support that step. I don't think it'll hurt anyone because the
> cards supported by i4l are mostly ISA cards anyway. The only exceptions
> are the HiSax family which is now supported by mISDN, and the Hypercope
> family which is supported by CAPI.
> 
> In the past we had Documentation/feature-removal-schedule.txt for
> announcing removals like that but Linus shot that down on 2012-10-01
> (commit 9c0ece069b32e8e122aea71aa47181c10eb85ba7) so I guess
> somebody could just submit a patch series starting with
> 
> --- a/drivers/isdn/Kconfig
> +++ b/drivers/isdn/Kconfig
> @@ -20,25 +20,6 @@ menuconfig ISDN
> 
>  if ISDN
> 
> -menuconfig ISDN_I4L
> -       tristate "Old ISDN4Linux (deprecated)"
> -       depends on TTY
> -       ---help---
> -         This driver allows you to use an ISDN adapter for networking
> -         connections and as dialin/out device.  The isdn-tty's have a
> built
> -         in AT-compatible modem emulator.  Network devices support
> autodial,
> -         channel-bundling, callback and caller-authentication without
> having
> -         a daemon running.  A reduced T.70 protocol is supported with
> tty's
> -         suitable for German BTX.  On D-Channel, the protocols EDSS1
> -         (Euro-ISDN) and 1TR6 (German style) are supported.  See
> -         <file:Documentation/isdn/README> for more information.
> -
> -         ISDN support in the linux kernel is moving towards a new API,
> -         called CAPI (Common ISDN Application Programming Interface).
> -         Therefore the old ISDN4Linux layer will eventually become
> obsolete.
> -         It is still available, though, for use with adapters that
> are not
> -         supported by the new CAPI subsystem yet.
> -
>  source "drivers/isdn/i4l/Kconfig"
> 
>  menuconfig ISDN_CAPI
> 
> and working its way from that to remove anything that's become
> unreachable.
> 
> Shall I?
> 

But I4L is still the default in some Distros, so we should allow a
warning period. But again, I'm fine with this to do it.

Karsten
