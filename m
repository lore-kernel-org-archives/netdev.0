From: Nick Krause <xerofoify@gmail.com>
Subject: Re: solos-pci.c: Fix me
Date: Mon, 21 Jul 2014 23:38:37 -0400
Message-ID: <CAPDOMVgW2jNR3n68QhbWh7EfTHRMYRNBrZkyKAA2x-T5ZO0ZiA@mail.gmail.com>
References: <CAPDOMVjnK=OF8mQrXbbgGUtCRJO8oG4+PQOETEcskNk=95GLrg@mail.gmail.com>
	<20140721091445.1ee700bb@thirdoffive.cmf.nrl.navy.mil>
	<CAPDOMVh7cx57GtxHk-_tmorSWSj6xci-YkDrecdCLJfTANbHAQ@mail.gmail.com>
	<20140721141851.7f270f4c@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:47773 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaGVDii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:38:38 -0400
In-Reply-To: <20140721141851.7f270f4c@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 2:18 PM, chas williams - CONTRACTOR
<chas@cmf.nrl.navy.mil> wrote:
> On Mon, 21 Jul 2014 13:42:01 -0400
> Nick Krause <xerofoify@gmail.com> wrote:
>
>> On Mon, Jul 21, 2014 at 9:14 AM, chas williams - CONTRACTOR
>> <chas@cmf.nrl.navy.mil> wrote:
> ...
>> > @@ -850,8 +850,7 @@ static void solos_bh(unsigned long card_arg)
>> >                                 dev_kfree_skb_any(skb);
>> >                                 break;
>> >
>> > -                       case PKT_COMMAND:
>> > -                       default: /* FIXME: Not really, surely? */
>> > +                       default: /* PKT_COMMAND */
>> >                                 if (process_command(card, port, skb))
>> >                                         break;power
>> >                                 spin_lock(&card->cli_queue_lock);
>> >
>> > and be done with it since that will preserve existing behavior.
>>
>>
>> My only question then is this function causing bugs as is?
>> Cheers Nick
>>
>
> It has been there since the first version of this driver was released.
> If it were breaking things, I would have to guess it would have been
> noticed by now.
>
> Just looking at the PKT_* defines, I would wildly guess that PKT_COMMAND
> PKT_POPEN and PKT_PCLOSE are all being handled via the PKT_COMMAND|default
> case.  If not, popen and pclose would be leaking a skb for each usage
> (which would be opening and closing the PVC -- not very often).
>
> popen and pclose just seem like specialized PKT_COMMAND types.
> process_command() woud ignore PKT_POPEN and PKT_PCLOSE since they aren't
> long enough to contain a command.  So maybe the comment should just go
> away.
>
> If you had access to hardware you could probably figure this out pretty
> quickly.  The programmer's manual doesn't seem to be available.


Seems based on your ideas , I can remove this FIX ME. I will send a patch
doing this.
Cheers Nick
