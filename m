From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] brcmfmac: added LED triggers for transmit/receive
Date: Mon, 17 Jul 2017 06:59:07 +0200
Message-ID: <CACna6ryGWij030XTnsC8Hi_M0kULZr1RErU9q77OfF2c=iLkiA@mail.gmail.com>
References: <20170707140941.122115-1-russell.joyce@york.ac.uk>
 <CACna6rzY84oWNMBfP8N4A=Sxst_8b-S+rTbZFQV0yFcOR5MceQ@mail.gmail.com>
 <B8983FA2-39CE-478B-80C9-F32E01856FE9@york.ac.uk> <60de1301-b4a3-95a7-117f-a953576655d9@broadcom.com>
 <C53F8AC9-8F95-4191-A1E4-177AA1D0DA20@york.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Alan Millard <alan.millard@york.ac.uk>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Marcel Holtmann <marcel@holtmann.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Tobias Klauser <tklauser@distanz.ch>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.
To: Russell Joyce <russell.joyce@york.ac.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C53F8AC9-8F95-4191-A1E4-177AA1D0DA20@york.ac.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 July 2017 at 17:01, Russell Joyce <russell.joyce@york.ac.uk> wrote:
> Thanks for your comments.
>
>> What I think Rafa=C5=82 is saying is that it would be better to have thi=
s
>> code in cfg80211 so other drivers including mac80211 could use it.
>
>
> While I agree that moving all wireless LED triggers to cfg80211 would be =
an
> ideal situation, it seems a bit out of scope for what I was trying to ach=
ieve.
> This would probably also require removing the mac80211 LED triggers (and =
any
> other similar triggers that might be created by specific wireless drivers=
 not
> using mac80211), in order to consolidate them in one place.
>
> Besides this, I'm not sure where exactly in cfg80211 this functionality w=
ould
> go (I assume it was originally put in mac80211 instead for a reason?),
> although I'm certainly no expert in this area of the kernel.

I don't expect you to rewrite all mac80211 drivers at this point. Just
focus on the generic cfg80211 helper and use it in brcmfmac. Other
cfg80211 drivers and mac80211 may follow in the future.

I'm not sure what's the best place in cfg80211 for this. Try
something, or try to get some comments from cfg80211 guys.


>> Indeed. However, the LED subsystem could/should(?) take care of mapping
>> "rx" and "tx" triggers to the same LED.
>
> In terms of the LED triggers, the only alternative I can see is to create=
 a
> single complex trigger that exposes "rx" and "tx" parameters that can be
> individually enabled or disabled. This would reduce the number of trigger=
s from
> three to one, but also makes things slightly more awkward for the user, a=
nd
> deviates from the convention set by mac80211.

Ideally we should have "rx" and "tx". LED subsystem should allow
assigning *both* (at the same time) to the LED.

I'll try to discuss with with LED guys this week.

Sorry, I was busy last week.

--=20
Rafa=C5=82
