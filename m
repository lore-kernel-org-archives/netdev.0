From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: solos-pci.c: Fix me
Date: Mon, 21 Jul 2014 14:18:51 -0400
Message-ID: <20140721141851.7f270f4c@thirdoffive.cmf.nrl.navy.mil>
References: <CAPDOMVjnK=OF8mQrXbbgGUtCRJO8oG4+PQOETEcskNk=95GLrg@mail.gmail.com>
	<20140721091445.1ee700bb@thirdoffive.cmf.nrl.navy.mil>
	<CAPDOMVh7cx57GtxHk-_tmorSWSj6xci-YkDrecdCLJfTANbHAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDOMVh7cx57GtxHk-_tmorSWSj6xci-YkDrecdCLJfTANbHAQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Jul 2014 13:42:01 -0400
Nick Krause <xerofoify@gmail.com> wrote:

> On Mon, Jul 21, 2014 at 9:14 AM, chas williams - CONTRACTOR
> <chas@cmf.nrl.navy.mil> wrote:
...
> > @@ -850,8 +850,7 @@ static void solos_bh(unsigned long card_arg)
> >                                 dev_kfree_skb_any(skb);
> >                                 break;
> >
> > -                       case PKT_COMMAND:
> > -                       default: /* FIXME: Not really, surely? */
> > +                       default: /* PKT_COMMAND */
> >                                 if (process_command(card, port, skb))
> >                                         break;power
> >                                 spin_lock(&card->cli_queue_lock);
> >
> > and be done with it since that will preserve existing behavior.
> 
> 
> My only question then is this function causing bugs as is?
> Cheers Nick
> 

It has been there since the first version of this driver was released.
If it were breaking things, I would have to guess it would have been
noticed by now.

Just looking at the PKT_* defines, I would wildly guess that PKT_COMMAND
PKT_POPEN and PKT_PCLOSE are all being handled via the PKT_COMMAND|default
case.  If not, popen and pclose would be leaking a skb for each usage
(which would be opening and closing the PVC -- not very often).

popen and pclose just seem like specialized PKT_COMMAND types.
process_command() woud ignore PKT_POPEN and PKT_PCLOSE since they aren't
long enough to contain a command.  So maybe the comment should just go
away.

If you had access to hardware you could probably figure this out pretty
quickly.  The programmer's manual doesn't seem to be available.
