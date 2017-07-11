From: Russell Joyce <russell.joyce@york.ac.uk>
Subject: Re: [PATCH] brcmfmac: added LED triggers for transmit/receive
Date: Tue, 11 Jul 2017 16:01:16 +0100
Message-ID: <C53F8AC9-8F95-4191-A1E4-177AA1D0DA20@york.ac.uk>
References: <20170707140941.122115-1-russell.joyce@york.ac.uk>
 <CACna6rzY84oWNMBfP8N4A=Sxst_8b-S+rTbZFQV0yFcOR5MceQ@mail.gmail.com>
 <B8983FA2-39CE-478B-80C9-F32E01856FE9@york.ac.uk>
 <60de1301-b4a3-95a7-117f-a953576655d9@broadcom.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
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
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Tobias Klauser <tklauser@distanz.ch>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.ker
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60de1301-b4a3-95a7-117f-a953576655d9@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your comments.

> What I think Rafa=C5=82 is saying is that it would be better to have =
this
> code in cfg80211 so other drivers including mac80211 could use it.


While I agree that moving all wireless LED triggers to cfg80211 would be =
an
ideal situation, it seems a bit out of scope for what I was trying to =
achieve.
This would probably also require removing the mac80211 LED triggers (and =
any
other similar triggers that might be created by specific wireless =
drivers not
using mac80211), in order to consolidate them in one place.

Besides this, I'm not sure where exactly in cfg80211 this functionality =
would
go (I assume it was originally put in mac80211 instead for a reason?),
although I'm certainly no expert in this area of the kernel.

> Indeed. However, the LED subsystem could/should(?) take care of =
mapping
> "rx" and "tx" triggers to the same LED.

In terms of the LED triggers, the only alternative I can see is to =
create a
single complex trigger that exposes "rx" and "tx" parameters that can be
individually enabled or disabled. This would reduce the number of =
triggers from
three to one, but also makes things slightly more awkward for the user, =
and
deviates from the convention set by mac80211.
