From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Wed, 21 Jan 2015 15:00:15 +0000
Message-ID: <20150121150015.31351.6605@shannon>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux> <20150121103319.14511.57709@shannon>
 <e5439ed067931dc01bda70592eb6ed52@grandegger.com>
 <20150121144323.GA17070@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0053.outbound.protection.outlook.com ([157.55.234.53]:41440
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753371AbbAUPAZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 10:00:25 -0500
In-Reply-To: <20150121144323.GA17070@linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Ahmed S. Darwish (2015-01-21 14:43:23)
> Hi!
> 
> On Wed, Jan 21, 2015 at 12:53:58PM +0100, Wolfgang Grandegger wrote:
> > On Wed, 21 Jan 2015 10:33:19 +0000, Andri Yngvason
> > <andri.yngvason@marel.com> wrote:
> > > Quoting Ahmed S. Darwish (2015-01-20 21:45:37)
> > >> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > >> 
> > >> Replace most of the can interface's state and error counters
> > >> handling with the new can-dev can_change_state() mechanism.
> > >> 
> > >> Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
> > >> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > >> ---
> > >>  drivers/net/can/usb/kvaser_usb.c | 114
> > >>  +++++++++++++++++++--------------------
> > >>  1 file changed, 55 insertions(+), 59 deletions(-)
> > >> 
> > >> diff --git a/drivers/net/can/usb/kvaser_usb.c
> > >> b/drivers/net/can/usb/kvaser_usb.c
> > >> index 971c5f9..0386d3f 100644
> > >> --- a/drivers/net/can/usb/kvaser_usb.c
> > >> +++ b/drivers/net/can/usb/kvaser_usb.c
> > 
> > ...
> > > 
> > > Looks good.
> > 
> > Would be nice to see some "candump" traces as well.
> 
> Sure. The USBCan-II device trace below is generated after applying
> all patches in the series, especially patch #3, which fixes some
> some invalid CAN state transitions logic in the original driver.
[...]
> 
> Afterwards, candump on a PC, Kvaser USB device on the sending end:
> 
>  ...
>  (000.008784)  can0  60A   [1]  C1
>  (000.011341)  can0  2A8   [8]  C2 0A 00 00 00 00 00 00
>  (000.009873)  can0  03D   [7]  C3 0A 00 00 00 00 00
>  (000.010394)  can0  55C   [8]  C4 0A 00 00 00 00 00 00
>  (000.009979)  can0  45A   [8]  C5 0A 00 00 00 00 00 00
>  (000.010125)  can0  6E8   [8]  C6 0A 00 00 00 00 00 00
>  (000.010149)  can0  4EE   [8]  C7 0A 00 00 00 00 00 00
>  (000.010102)  can0  5D2   [8]  C8 0A 00 00 00 00 00 00
>  (000.010000)  can0  61F   [8]  C9 0A 00 00 00 00 00 00
>  (000.010271)  can0  5F8   [8]  CA 0A 00 00 00 00 00 00
> 
> <-- Unplug the cable -->
> 
>  (000.009106)  can0  20000080   [8]  00 00 00 00 00 00 08 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{8}{0}}
>  (000.001872)  can0  20000080   [8]  00 00 00 00 00 00 10 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{16}{0}}
[...]
>         error-counter-tx-rx{{80}{0}}
>  (000.001910)  can0  20000080   [8]  00 00 00 00 00 00 58 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{88}{0}}
>  (000.001753)  can0  20000084   [8]  00 08 00 00 00 00 60 00   ERRORFRAME
>         controller-problem{tx-error-warning}
Good.
>         bus-error
>         error-counter-tx-rx{{96}{0}}
>  (000.001720)  can0  20000080   [8]  00 00 00 00 00 00 68 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{104}{0}}
>  (000.001876)  can0  20000080   [8]  00 00 00 00 00 00 70 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{112}{0}}
>  (000.001749)  can0  20000080   [8]  00 00 00 00 00 00 78 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{120}{0}}
>  (000.001771)  can0  20000084   [8]  00 20 00 00 00 00 80 00   ERRORFRAME
>         controller-problem{tx-error-passive}
Also good.
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.001868)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.001982)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
> 
> (( Then a continous flood, exactly similar to the above packet, appears.
>    Unfortunately this flooding is a firmware problem. ))
> 
> <-- Replug the cable, after a good amount of time -->
>
Where are the reverse state transitions?
> 
>  (000.520485)  can0  33D   [4]  CB 0A 00 00
>  (000.002693)  can0  42E   [8]  CC 0A 00 00 00 00 00 00
>  (000.001795)  can0  319   [4]  CD 0A 00 00
>  (000.002705)  can0  3B1   [8]  CE 0A 00 00 00 00 00 00
>  (000.001295)  can0  4CC   [2]  CF 0A
>  (000.002205)  can0  42B   [6]  D0 0A 00 00 00 00
>  (000.001620)  can0  5A2   [3]  D1 0A 00
>  (000.002636)  can0  691   [8]  D2 0A 00 00 00 00 00 00
>  (000.002615)  can0  36A   [8]  D3 0A 00 00 00 00 00 00
>  (000.001729)  can0  068   [4]  D4 0A 00 00
>  (000.001195)  can0  4C8   [1]  D5
>  ...
> 
> ##########################################################################
> 
> Bus-off Testing:
> 
> candump on a PC, Kvaser device on the sending end. An i.mx6 ARM
> board with flexcan is on the receiving end:
> 
>  (000.010319)  can0  5CC   [8]  90 02 00 00 00 00 00 00
>  (000.008747)  can0  679   [1]  91
>  (000.011442)  can0  011   [8]  92 02 00 00 00 00 00 00
>  (000.008991)  can0  631   [2]  93 02
>  (000.011097)  can0  532   [7]  94 02 00 00 00 00 00
>  (000.009781)  can0  0A9   [5]  95 02 00 00 00
>  (000.010792)  can0  1DD   [8]  96 02 00 00 00 00 00 00
>  (000.010026)  can0  44E   [8]  97 02 00 00 00 00 00 00
>  (000.010181)  can0  76A   [8]  98 02 00 00 00 00 00 00
>  (000.008867)  can0  1A5   [1]  99
>  (000.011322)  can0  2B4   [8]  9A 02 00 00 00 00 00 00
> 
> <-- Unplug the can low and high wires from the board -->
> 
>  (000.009688)  can0  20000080   [8]  00 00 00 00 00 00 08 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{8}{0}}
>  (000.002246)  can0  20000080   [8]  00 00 00 00 00 00 10 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{16}{0}}
>  (000.002124)  can0  20000080   [8]  00 00 00 00 00 00 18 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{24}{0}}
>  (000.002115)  can0  20000080   [8]  00 00 00 00 00 00 20 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{32}{0}}
>  (000.002132)  can0  20000080   [8]  00 00 00 00 00 00 28 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{40}{0}}
>  (000.002266)  can0  20000080   [8]  00 00 00 00 00 00 30 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{48}{0}}
>  (000.002187)  can0  20000080   [8]  00 00 00 00 00 00 38 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{56}{0}}
>  (000.002046)  can0  20000080   [8]  00 00 00 00 00 00 40 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{64}{0}}
>  (000.002076)  can0  20000080   [8]  00 00 00 00 00 00 48 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{72}{0}}
>  (000.002406)  can0  20000080   [8]  00 00 00 00 00 00 50 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{80}{0}}
>  (000.001969)  can0  20000080   [8]  00 00 00 00 00 00 58 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{88}{0}}
>  (000.002388)  can0  20000084   [8]  00 08 00 00 00 00 60 00   ERRORFRAME
>         controller-problem{tx-error-warning}
>         bus-error
>         error-counter-tx-rx{{96}{0}}
>  (000.002021)  can0  20000080   [8]  00 00 00 00 00 00 68 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{104}{0}}
>  (000.002110)  can0  20000080   [8]  00 00 00 00 00 00 70 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{112}{0}}
>  (000.002155)  can0  20000080   [8]  00 00 00 00 00 00 78 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{120}{0}}
>  (000.002140)  can0  20000084   [8]  00 20 00 00 00 00 80 00   ERRORFRAME
>         controller-problem{tx-error-passive}
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.002324)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.002416)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.002237)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
> 
> (( Then a continous flood, exactly similar to the above packet, appears ))
> 
> <-- Short-circuit the can high and low wires -->
> 
>  (000.002364)  can0  20000080   [8]  00 00 00 00 00 00 80 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{128}{0}}
>  (000.002108)  can0  20000080   [8]  00 00 00 00 00 00 88 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{136}{0}}
>  (000.000494)  can0  20000080   [8]  00 00 00 00 00 00 90 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{144}{0}}
>  (000.000523)  can0  20000080   [8]  00 00 00 00 00 00 98 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{152}{0}}
>  (000.000661)  can0  20000080   [8]  00 00 00 00 00 00 A0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{160}{0}}
>  (000.000464)  can0  20000080   [8]  00 00 00 00 00 00 A8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{168}{0}}
>  (000.000534)  can0  20000080   [8]  00 00 00 00 00 00 B0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{176}{0}}
>  (000.000499)  can0  20000080   [8]  00 00 00 00 00 00 B8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{184}{0}}
>  (000.000626)  can0  20000080   [8]  00 00 00 00 00 00 C0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{192}{0}}
>  (000.000373)  can0  20000080   [8]  00 00 00 00 00 00 C8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{200}{0}}
>  (000.000627)  can0  20000080   [8]  00 00 00 00 00 00 D0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{208}{0}}
>  (000.000507)  can0  20000080   [8]  00 00 00 00 00 00 D8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{216}{0}}
>  (000.000501)  can0  20000080   [8]  00 00 00 00 00 00 E0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{224}{0}}
>  (000.000459)  can0  20000080   [8]  00 00 00 00 00 00 E8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{232}{0}}
>  (000.000606)  can0  20000080   [8]  00 00 00 00 00 00 F0 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{240}{0}}
>  (000.000454)  can0  20000080   [8]  00 00 00 00 00 00 F8 00   ERRORFRAME
>         bus-error
>         error-counter-tx-rx{{248}{0}}
>  (000.000664)  can0  200000C0   [8]  00 00 00 00 00 00 00 00   ERRORFRAME
>         bus-off
>         bus-error
> 
>  (( No further bus activity ))
> 
Bus-off seems OK. You could have just short circuited them without
disconnecting.

Reverse state transitions are missing from the logs. See comments above.

--
Andri
