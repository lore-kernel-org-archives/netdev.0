From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 wpa update
Date: Tue, 29 Jun 2004 18:49:30 -0700
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040630014930.GB7153@jm.kir.nu>
References: <20040629192101.GB14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Content-Disposition: inline
In-Reply-To: <20040629192101.GB14482@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 03:21:01PM -0400, Luis R. Rodriguez wrote:

> I'll keep my latest wpa work/patch at the following URL:
> 
> http://prism54.org/~mcgrof/prism54-wpa.diff

Hmm.. I do not understand the change you did for priv->wpa processing.
There seems to be some kind of misunderstanding on what DOT11_AUTHENABLE
and DOT11_OID_MLMEAUTOLEVEL is set to in various mode. I do not fully
understand what you mean with TKIP vs 802.1x. TKIP is an encryption
algorithm like WEP. IEEE 802.1X is authentication protocol which can be
used with IEEE 802.1X EAPOL-Key frames to distribute WEP keys _or_ with
WPA to generate keying material for WPA 4-Way Handshake that will
generate the data encryption keys.

DOT11_AUTHENABLE should be set to DOT11_AUTH_OS for WPA modes (i.e., not
_SK or _BOTH like you had in some cases). DOT11_AUTH_SK can only be used
with static WEP configuration (i.e., not with WPA or with IEEE 802.1X
when using dynamic WEP key generation). DOT11_AUTH_BOTH is likewise only
reasonable for static WEP configuration since it includes _SK as an
option. DOT11OID_MLMEAUTOLEVEL seems to be required to be
DOT11_MLME_EXTENDED for all cases where WPA IE is used.

-- 
Jouni Malinen                                            PGP id EFC895FA
