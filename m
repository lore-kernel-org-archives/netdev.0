From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: RFC: Linux wireless extensions and WPA support
Date: Sun, 13 Jun 2004 13:11:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040613201134.GC7327@jm.kir.nu>
References: <386CBF9421521B41835E2BF21BEF80B8968D33@hasmsx402.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andonieh, Joe" <joe.andonieh@intel.com>
Content-Disposition: inline
In-Reply-To: <386CBF9421521B41835E2BF21BEF80B8968D33@hasmsx402.ger.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 09, 2004 at 09:23:23AM +0300, Andonieh, Joe wrote:

> 	Thinking about access point we need a way to set more than one
> cipher suite for the pairwise cipher list (for example mixed mode, which
> have both TKIP and CCMP users.
> 
> Another aspect is an AP that wants to support more than one mode of
> operation, for example; advertise both WPA and RSN IE, or both WPA .1X
> and WPA PSK?

These both can use the generic IE mechanism (SIOCSIWGENIE) to configure
whatever mode is needed. I'm more used to doing the policy decision in
user space (e.g., validating WPA/RSN IE in AssocReq), so there has not
been much need in pushing all the information to the driver.

Of course, we could change the IW_AUTH_ parameters for cipher and key
management suites to use bit field. This limits the number of options to
32, but that should be enough and if not, can be extended in the future.
IW_AUTH_ALG_ is already doing this anyway and IW_AUTH_WPA_VERSION_ has
only two values, so it works as a bit field already (just needs to be
documented as such).

> From the Client Perspective; isn't it better Idea for the station decide
> or match an access point to connect with depending on the pairwise
> cipher only? For example a client that supports CCMP can connect to both
> access point where each one may be working in different mode, WPA --
> CCMP as both pair wise and group ciphers or with an AP in mixed mode
> which have CCMP as pairwise and TKIP as groupcast cipher.

The group cipher could be anything from WEP40 to CCMP and I want to be
able to configure the client to reject APs that do not meet the
current policy (which might be, "require CCMP"). Doing the selection
only based on pairwise cipher would thus not be enough.

Changing the IW_AUTH_ parameters to be bitfields would help here, too,
for the case of client drivers that want to do the WPA/RSN IE processing
in the driver instead of letting Supplicant take care of this. Actually,
this reminded me of another thing I forgot: we should add reporting of
the exact IE that was used in (Re)AssocReq as a wireless event to the
Supplicant so that this case of WPA/RSN IE being generated in the
driver is supported.

-- 
Jouni Malinen                                            PGP id EFC895FA
