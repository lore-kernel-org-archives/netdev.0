From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: Udev coldplugging loads 8139too driver instead of 8139cp
Date: Tue, 29 Jan 2008 17:53:16 +0100
Message-ID: <200801291753.18578.linux@rainbow-software.org>
References: <1201554992.13883.13.camel@Anastacia> <20080128170830.6f67fa5a@deepthought> <479F0369.3080309@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystems.sk ([62.176.172.50]:36262 "EHLO www.gsystems.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519AbYA2Qx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 11:53:56 -0500
In-Reply-To: <479F0369.3080309@msgid.tls.msk.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 January 2008 11:43:53 Michael Tokarev wrote:
> Stephen Hemminger wrote:
> > On Tue, 29 Jan 2008 03:46:08 +0300
> > Michael Tokarev <mjt@tls.msk.ru> wrote:
>
> []
>
> >> There are 2 drivers for 8139-based NICs.  For really different two kinds
> >> of hardware, which both uses the same PCI identifiers.  Both drivers
> >> "claims" to work with all NICs with those PCI ids, because "externally"
> >> (by means of udev for example) it's impossible to distinguish the two
> >> kinds of hardware, it becomes clean only when the driver (either of the
> >> two) loads and actually checks which hardware we have here.
> >
> > Is there any chance of using subdevice or subversion to tell them apart?
> > That worked for other vendors like DLINK who slapped same ID on different
> > cards.
>
> If it were that simple... ;)
>
> No.  The difference is in PCI revision number (byte #8 in PCI config
> space). If it's >= 0x40 - it's 8139too, < 0x40 - 8139cp.  Or 0x20 - I
> forgot.

Perhaps a module could be created that will claim this device ID and then use 
the correct driver.

> Here's a code snippet from a shell script I used ages ago to automatically
> load modules (similar to what udev does nowadays):
>
>   # special hack for 8139{too,cp} stuff
>   case "$modalias" in
>   *v000010ECd00008139*)
>     rev="$(dd if="$1/config" bs=1 skip=8 count=1 2>/dev/null)"
>     if [ -n "$rev" ]; then
>       list=
>       for module in $modlist; do
>         case "$module" in
>         8139cp)
>           if [ ".$rev" \< ". " ]; then
>             $vecho1 "$TAG: not loading $module for this device"
>             continue
>           fi
>           ;;
>         8139too)
>           if [ ".$rev" \> ". " ]; then
>             $vecho1 "$TAG: not loading $module for this device"
>             continue
>           fi
>           ;;
>         esac
>         list="$list $module"
>       done
>       modlist="$list"
>     fi
>     ;;
>   esac
>
> /mjt
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Ondrej Zary
