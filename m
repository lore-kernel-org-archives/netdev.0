From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net/dl2k: Don't reconfigure link @100Mbps when
 disabling autoneg @1Gbps
Date: Tue, 10 May 2011 19:55:07 +0100
Message-ID: <1305053707.2859.57.camel@bwh-desktop>
References: <1304986748-15809-1-git-send-email-decot@google.com>
	 <1304986748-15809-3-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304986748-15809-3-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-09 at 17:19 -0700, David Decotigny wrote:
> The initial version of the driver used to force the link to 100Mbps
> when auto-negociation was disabled on a 1Gbps link, ignoring the
> requested link speed. Instead, this change refuses to change anything
> when it is asked to configure the link speed at 1Gbps without
> auto-negociation, but acts as requested in all the other cases.
> 
> IMPORTANT: Previously, the return value from mii_set_media() was
>            ignored. This patch uses it for its own return value.
> 
> Tested: module compiling, NOT tested on real hardware.
> Signed-off-by: David Decotigny <decot@google.com>
[...]

The changes to validation look fine.  However, I noticed that there's a
call to netif_carrier_off() at the top of this function.  This means
that in the error and shortcut cases, the interface will be left
disabled!  It's an existing bug but might be made slightly worse by this
change.

Please also move the call to netif_carrier_off() down to the end, just
before the call to mii_set_media() which actually alters the link.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
