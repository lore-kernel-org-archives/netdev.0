From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Thu, 5 Jan 2017 23:25:08 +0000
Message-ID: <20170105232508.GU14217@n2100.armlinux.org.uk>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Alexandre TORGUE <alexandre.torgue@st.com>,
 Neil Armstrong <narmstrong@baylibre.com>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 netdev@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 linux-kernel@vger.kernel.org, Yegor Yefremov <yegorslists@googlemail.com>,
 Julia Lawall <julia.lawall@lip6.fr>, Andre Roth <neolynx@gmail.com>,
 Andrew Lunn <andrew@lunn.ch>, Kevin Hilman <khilman@baylibre.com>,
 Carlo Caione <carlo@caione.org>, linux-amlogic@lists.infradead.org,
 Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
 linux-arm-kernel@lists.infradead.org, Jerome Brunet <jbrunet@baylibre.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 09:54:28AM -0800, Florian Fainelli wrote:
> If we start supporting generic "enable", "disable" type of properties
> with values that map directly to register definitions of the HW, we
> leave too much room for these properties to be utilized to implement a
> specific policy, and this is not acceptable.

Another concern with this patch is that the existing phylib "set_eee"
code is horribly buggy - it just translates the modes from userspace
into the register value and writes them directly to the register with
no validation.  So it's possible to set modes in the register that the
hardware doesn't support, and have them advertised to the link partner.

I have a patch which fixes that, restricting (as we do elsewhere) the
advert according to the EEE supported capabilities retrieved from the
PCS - maybe the problem here is that the PCS doesn't support support
EEE in 1000baseT mode?

Out of interest, which PHY is used on this platform?

On the SolidRun boards, they're using AR8035, and have suffered this
occasional link drop problem.  What has been found is that it seems to
be to do with the timing parameters, and it seemed to only be 1000bT
that was affected.  I don't remember off hand exactly which or what
the change was they made to stabilise it though, but I can probabily
find out tomorrow.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
