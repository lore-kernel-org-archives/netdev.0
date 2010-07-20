From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: net/dsa
Date: Tue, 20 Jul 2010 23:28:19 +0200
Message-ID: <AANLkTinBA3uqfML78PRr1-xN2ye_3Pjj-NQE5t7eHxGy@mail.gmail.com>
References: <4C3B8231.6020706@gmail.com>
	<20100720135950.GZ14513@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50559 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597Ab0GTV2U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 17:28:20 -0400
Received: by wwj40 with SMTP id 40so1393708wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 14:28:19 -0700 (PDT)
In-Reply-To: <20100720135950.GZ14513@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 3:59 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Mon, Jul 12, 2010 at 10:59:29PM +0200, Karl Beldan wrote:
>
>> Hi,
>
> Hi Karl,
>
> Sorry, I didn't see your mail initially -- please CC me in the future=
=2E
>
>
>> I found the dsa code very handy to help manage a switch.
>
> Ah. =A0What particular part are you using?
>
>
The whole thing but the cascading stuff.
I could even reuse a tagging format almost as is!

>> Yet I was surprised I had to tweak the code to simply use the phy
>> layer state machine.
>
> You mean that net/dsa uses phy_attach() but not phy_start_machine() ?
> Have you seen problems arising from this?
>
>
I did not mean that, but I do not think there would be a problem,
since every in-tree driver provide their poll_link() to do the job of
the phylib's state_queue, unless one does not provide its poll_link(),
I guess this is what you had in mind.
What I had in mind in fact was the re-use of the phylib's interrupt
based code, in this situation poll_link() is not there, but there
replacing phy_attach() with phy_start_machine is not enough.
Those are not big changes, but the code seems to aim at such versatile
behavior (and more), I can only imagine it would be useful for the
plethora of boards embedding a switch.

>> And I don't see much activity in the code nor any discussion, e.g no
>> follow up to http://patchwork.ozlabs.org/patch/16578.
>>
>> So I was wondering if there was anybody playing with this code, or
>> having ideas about features to add (vlan/stp callbacks) ?
>
> As far as I know, the code currently in the kernel works well for wha=
t
> it intends to do (which is to just expose the switch ports), and I'm
> not aware of any bugs in it.
>
> That said, you're right in that there are several more features that
> the hardware supports that the software could be extended to handle.
>
> For one, I don't have access to any Marvell switch chip hardware
> anymore, so that limits my ability to play with this. =A0Also, the
> relevant documentation is under a rather restrictive license, so the
> only way I can see net/dsa support for Marvell parts improving is if
> there's pressure from a large enough customer to make this happen.
>
Now I understand, but still, I am surprised nobody else touched the
code, with all those switches in the embedded business.

> If this is about non-Marvell parts, I'd welcome adding support for
> those into net/dsa. =A0For one, I would really like to see Broadcom
> switch chip support added -- the documentation for those chips is
> under similarly restrictive licensing, though.
>
>

Thanks,

Karl
