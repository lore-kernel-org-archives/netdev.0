From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 2/3] net: dsa: lan9303: define
 LAN9303_NUM_PORTS 3
Date: Tue, 1 Aug 2017 15:27:28 +0200
Message-ID: <20170801132728.GA23157@lunn.ch>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no>
 <20170801111439.1143-3-privat@egil-hjelmeland.no>
 <201708011349.52529.jbe@pengutronix.de>
 <10b6b9fc-d2f9-1761-802f-724d9f6b3df1@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juergen Borleis <jbe@pengutronix.de>, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <10b6b9fc-d2f9-1761-802f-724d9f6b3df1@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 02:31:44PM +0200, Egil Hjelmeland wrote:
> On 01. aug. 2017 13:49, Juergen Borleis wrote:
> >Hi Egil,
> >
> >On Tuesday 01 August 2017 13:14:38 Egil Hjelmeland wrote:
> >>Will be used instead of '3' in upcomming patches.
> >>
> >>
> >>+#define LAN9303_NUM_PORTS 3
> >>+
> >
> >Maybe we should put this macro into a shared location because
> >in "net/dsa/tag_lan9303.c" there is already a "#define LAN9303_MAX_PORTS
> >3".
> >
> >jb
> >
> 
> Is there any suitable shared location for such driver specific
> definitions?
> I could change the name to LAN9303_MAX_PORTS so it the same.
> Rhymes better with DSA_MAX_PORTS too.

Hi Egil, Juergen

The other tag drivers do:

        if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
                return NULL;

or just

        if (!ds->ports[port].netdev)
                return NULL;

The first version is the safest, since a malicious switch could return
port 42, and you are accessing way off the end of ds->ports[]. It does
however require you call dsa_switch_alloc() with the correct number of
ports.

     Andrew
