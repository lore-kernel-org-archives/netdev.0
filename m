From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age
 and port_fdb_dump methods
Date: Fri, 20 Oct 2017 08:59:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009D4AB@AcuExch.aculab.com>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20171019141505.GA14840@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD009C922@AcuExch.aculab.com>
 <35825cd2-0b47-3f8a-813e-1e7db2f7dcde@egil-hjelmeland.no>
 <e3017724-b555-a021-c4b3-49a754201861@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Egil Hjelmeland' <privat@egil-hjelmeland.no>,
        'Andrew Lunn' <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e3017724-b555-a021-c4b3-49a754201861@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland
> Sent: 19 October 2017 17:53
...
> >> IMHO it is best to define a struct for the 'ctx and then do:
> >>     ..., void *v_ctx)
> >> {
> >>     foo_ctx *ctx = v_ctx;
> >>     int port = ctx->port;
> >>
> >> That stops anyone having to double-check that the *(int *)
> >> is operating on a pointer to an integer of the correct size.
> >>
> >
> > Does casting to a struct pointer require less manual double-check than
> > to a int-pointer? In neither cases the compiler can protect us, IFAIK.
> > But on the other hand, a the text "foo_ctx" can searched in the editor.
> > So in that respect it can somewhat aid to the double-checking.
> >
> > So I can do that.
> >
> >
> 
> I understand now that the caller side (lan9303_port_fast_age) is
> vulnerable. Say somebody has the idea to change the "port" param
> of .port_fast_age from int to u8, then my code is a trap.

Worse, change it to a long and it will work on everything except
64bit big-endian systems.

	David
