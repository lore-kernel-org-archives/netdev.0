From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: RFC: Linux wireless extensions and WPA support
Date: Mon, 14 Jun 2004 15:50:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614225058.GA3160@bougret.hpl.hp.com>
References: <386CBF9421521B41835E2BF21BEF80B89B6211@hasmsx402.ger.corp.intel.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andonieh, Joe" <joe.andonieh@intel.com>
Content-Disposition: inline
In-Reply-To: <386CBF9421521B41835E2BF21BEF80B89B6211@hasmsx402.ger.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 11:56:03AM +0300, Andonieh, Joe wrote:
> 
> > Of course, we could change the IW_AUTH_ parameters for cipher and key
> > Management suites to use bit field. This limits the number of options
> to
> > 32, but that should be enough and if not, can be extended in the
> future.
> > IW_AUTH_ALG_ is already doing this anyway and IW_AUTH_WPA_VERSION_ has
> > Only two values, so it works as a bit field already (just needs to be
> > Documented as such).
> 
> I Guess this is a better approach to have it as a bit mask -- Maybe I s
> till do not understand the interface correctly, but still I can't see
> how the user can set the pairwise cipher separately from the group
> cipher? The interface show 
> +/* IW_AUTH_PAIRWISE_CIPHER and IW_AUTH_GROUP_CIPHER values */
> +#define IW_AUTH_CIPHER_NONE	0
> +#define IW_AUTH_CIPHER_WEP40	1
> +#define IW_AUTH_CIPHER_TKIP	2
> +#define IW_AUTH_CIPHER_CCMP	4
> +#define IW_AUTH_CIPHER_WEP104	5
> 
> But not specify which is what?

	You missed the other part of the API :

+/* SIOCSIWAUTH/SIOCGIWAUTH parameters (0 .. 4095)
+ * (IW_AUTH_INDEX mask in struct iw_param flags; this is the index of the
+ * parameter that is being set/get to; value will be read/written to
+ * struct iw_param value field) */
+#define IW_AUTH_WPA_VERSION    0
+#define IW_AUTH_CIPHER_PAIRWISE        1
+#define IW_AUTH_CIPHER_GROUP   2
+#define IW_AUTH_KEY_MGMT       3
+#define IW_AUTH_TKIP_COUNTERMEASURES   4
+#define IW_AUTH_DROP_UNENCRYPTED       5
+#define IW_AUTH_80211_AUTH_ALG 6

	If you combine both definitions, you get exactly what you
want.
	Note that in this case, I'm with Jouni, I think a bitmask
may be too limitative in the long run...

> Thanks
> Joe

	Have fun...

	Jean
