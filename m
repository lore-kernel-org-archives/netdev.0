From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [Prism54-devel] Re: Prism54 wpa update
Date: Wed, 30 Jun 2004 11:13:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630151346.GE14482@ruslug.rutgers.edu>
References: <20040629192101.GB14482@ruslug.rutgers.edu> <20040630014930.GB7153@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
Content-Disposition: inline
In-Reply-To: <20040630014930.GB7153@jm.kir.nu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 06:49:30PM -0700, Jouni Malinen wrote:
> On Tue, Jun 29, 2004 at 03:21:01PM -0400, Luis R. Rodriguez wrote:
> 
> > I'll keep my latest wpa work/patch at the following URL:
> > 
> > http://prism54.org/~mcgrof/prism54-wpa.diff
> 
> Hmm.. I do not understand the change you did for priv->wpa processing.
> There seems to be some kind of misunderstanding on what DOT11_AUTHENABLE
> and DOT11_OID_MLMEAUTOLEVEL is set to in various mode. 

First, thanks for the reply.

In regards to MLME, that was just a big fat typo. 

> I do not fully
> understand what you mean with TKIP vs 802.1x. TKIP is an encryption
> algorithm like WEP. IEEE 802.1X is authentication protocol which can be
> used with IEEE 802.1X EAPOL-Key frames to distribute WEP keys _or_ with
> WPA to generate keying material for WPA 4-Way Handshake that will
> generate the data encryption keys.

Yes, sorry, what I was trying to distinguish was using WPA using either
PSK or 802.1x for 4-way handshake. I did not know there were two 802.1x key
mechanisms though, as you point out. Wherever I said just TKIP I meant over TKIP
using a PSK. I believe the second mode of 802.1x can be used with this
chipset, not sure of the first though (to distribute WEP keys).

> DOT11_AUTHENABLE should be set to DOT11_AUTH_OS for WPA modes (i.e., not
> _SK or _BOTH like you had in some cases). DOT11_AUTH_SK can only be used
> with static WEP configuration (i.e., not with WPA or with IEEE 802.1X
> when using dynamic WEP key generation). DOT11_AUTH_BOTH is likewise only
> reasonable for static WEP configuration since it includes _SK as an
> option. 

OS stands for Open System here. Are you sure of this? I'll ask around, just to
confirm too.

> DOT11OID_MLMEAUTOLEVEL seems to be required to be
> DOT11_MLME_EXTENDED for all cases where WPA IE is used.

Yes, this I am aware of this. I've regenerated my patch. This *is* what
I meant. I think then we just need to clear up on what values should be
set for AUTHENABLE. I assumed the filter settings should work as I noted
but I am not yet sure obviously since I cannot test yet.

Last note is just keep in my that the patch is not supposed to work, its
more of work in progress, particularly turning the radio off involves
more work than what I currently have there. That is what I spend last
night working on. I'll try to finish that off first before I move on to 
trying to detect WPA IEs.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
