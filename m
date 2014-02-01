From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 2/2] of_mdio: Allow the DT to specify the phy ID and
 avoid autoprobing
Date: Fri, 31 Jan 2014 18:01:50 -0700
Message-ID: <20140201010150.GB2519@obsidianresearch.com>
References: <1391205045-1751-1-git-send-email-jgunthorpe@obsidianresearch.com>
 <1391205045-1751-2-git-send-email-jgunthorpe@obsidianresearch.com>
 <CAGVrzcbVo-Zzm9kLhiptf-qWgPH9XSs29mW8g2=g=Bq=PCb0_w@mail.gmail.com>
 <20140131225513.GA2519@obsidianresearch.com>
 <CAGVrzcZwkHSLJxpVsVY_6-VnsuODs0vGKcrcvSBzMEq3GWxqLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcZwkHSLJxpVsVY_6-VnsuODs0vGKcrcvSBzMEq3GWxqLA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 31, 2014 at 03:28:10PM -0800, Florian Fainelli wrote:
> - you tell of_mdiobus_register() to look for a reset phandle and have
> a reset controller release the PHY from reset before it tries to probe
> for it, because doing that could avoid doing the PHY out of reset
> sequence in a few dozen Ethernet drivers

I think this would be interesting, but difficult. Ideally you'd want
to keep the phy in reset until an ethernet driver attaches to it, and
reset it again once it detaches, so Linux would have to defer probing
the phy driver until an attach. Not sure what this would do for power
consumption, but reset might be lower power on phy's that don't have
an internal power down.

> The auto-probing bypass logic looks simple enough, and it does not
> require burying the reset logic behind a reset controller, which
> uses

Right, it closely matches what was happening in board files. FWIW,
this system was designed in 2005 for Linux 2.16 and this patch set fell
out of porting forward to 3.13 w/ DT.

Jason
