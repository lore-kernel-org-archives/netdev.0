From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [2/3] via-rhine: de-isolate PHY
Date: Sun, 8 Aug 2004 23:54:58 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040808215458.GA21994@k3.hellgate.ch>
References: <411684D5.8020302@colorfullife.com> <20040808200532.GA19170@k3.hellgate.ch> <41169546.5000308@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265038AbUHHVzS@vger.kernel.org>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <41169546.5000308@colorfullife.com>
List-Id: netdev.vger.kernel.org

On Sun, 08 Aug 2004 23:04:06 +0200, Manfred Spraul wrote:
> Roger Luethi wrote:
> >>I know that PHYs go into isolate mode if the startup id is wired to 0, 
> >
> >Wouldn't that be s/go/can go/ ?
> >
> I don't have the MII standard, my knowledge is from the DP83840A specs:
> The pin description contains a section about the phy ids:
> During power up five pins are latched to determine the initial phy address.
> Then the following sentence in bold: "An address selection of all zeros 
> (00000) will result in a PHY isolation condition".

I suppose all PHYs do that. Even if they don't, though, I should be
safe as long as I de-isolate unconditionally (instead of testing for
phy_id==0).

> I've reread the DP specs and I now think that your current patch is 
> sufficient:
> The isolate state is independant from the phy address - a non-zero phy 
> can be in isolate mode and the phy zero can be non-isolated. The phy id 

Stands to reason. A PHY that can't get out of isolation wouldn't be
very useful.

> If this is really true then handling phy 0 is trivial:
> First scan 1-31. If nothing found: try 0. If a phy is found: clear the 
> isolate bit and then use phy 0.

Makes sense. The Rhine is actually pretty neat in that regard, I've
been able to drop the PHY scanning entirely.

Roger
