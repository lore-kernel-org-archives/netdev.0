From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Sun, 15 Nov 2015 21:04:58 +0100
Message-ID: <201511152104.59206.linux@rainbow-software.org>
References: <1447538738-28605-1-git-send-email-linux@rainbow-software.org> <CAHp75VehDXoMNsXD08Et9Z5Pds+7Xf5+PXHE2pFzh4Srs-Tw+A@mail.gmail.com> <20151115.125905.63907005203700143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andy.shevchenko@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151115.125905.63907005203700143.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 November 2015 18:59:05 David Miller wrote:
> From: Andy Shevchenko <andy.shevchenko@gmail.com>
> Date: Sun, 15 Nov 2015 04:30:25 +0200
>
> > On Sun, Nov 15, 2015 at 12:05 AM, Ondrej Zary
> >
> >> @@ -433,9 +474,10 @@ rio_open (struct net_device *dev)
> >>
> >>         alloc_list (dev);
> >>
> >> -       /* Get station address */
> >> -       for (i = 0; i < 6; i++)
> >> -               dw8(StationAddr0 + i, dev->dev_addr[i]);
> >> +       /* Set station address */
> >> +       for (i = 0; i < 3; i++)
> >> +               dw16(StationAddr0 + 2 * i,
> >> +                    cpu_to_le16(((u16 *)dev->dev_addr)[i]));
> >
> > Is it specific requirement for new HW? If not, may be another patch
> > with micro optimizations.
>
> I absolutely agree, this definitely should not just be blindly copied
> over from the other driver.
>
> And if it is a requirement:

Yes, it's required. The byte access does not work on IP1000A chips.

> 1) It must be documented as per why, both in a comment above the loop
>    and in the commit log message.

OK.

> 2) It must therefore be tested on dl2k chips that worked with the
>    dl2k driver beforehand to prove that it doesn't break them.

Tested it with D-Link DGE-550T (chip marked DL-2000, probably rebranded 
TC9020) and it works fine.
Even the TC9020 datasheet says: "Access Rule: Word, Double Word". So it was 
always wrong but worked anyway.

-- 
Ondrej Zary
