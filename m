From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.7-bk19] prism54 freq to channel
	incorrect for 5GHz
Date: Wed, 7 Jul 2004 08:31:47 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407070831.47896.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Jeff scribeth:
> any comment on Sam's comment ?

Sam was referring to this from the sourceforge madwifi
project :
 * Convert MHz frequency to IEEE channel number.
 */
u_int
ieee80211_mhz2ieee(u_int freq, u_int flags)
{
        if (flags & IEEE80211_CHAN_2GHZ) {      /* 2GHz band */
                if (freq == 2484)
                        return 14;
                if (freq < 2484)
                        return (freq - 2407) / 5;
                else
                        return 15 + ((freq - 2512) / 20);
        } else if (flags & IEEE80211_CHAN_5GHZ) {       /* 5Ghz band */
                return (freq - 5000) / 5;
        } else {                                /* either, guess */
                if (freq == 2484)
                        return 14;
                if (freq < 2484)
                        return (freq - 2407) / 5;
                if (freq < 5000)
                        return 15 + ((freq - 2512) / 20);
                return (freq - 5000) / 5;
        }
}

Mostly, the wirless drivers (airo, orinoco, prism54, etc) have a table for the
freq's.
For something generic, I would suggest something like this :
u_int
ieee80211_freq_to_channel(u_int freq)
{
	/* 2.4 GHz channel 14 */
	if ( freq == 2484 )
		return 14;
	/* 2.4 GHz channels 1 - 13 */
	if ( freq >= 2412 && freq <= 2472 )
		return (freq - 2407) / 5;
	/* 2.4 GHz unofficial channels */
	if ( freq > 2484 && freq < 5000 )
		return 15 + ((freq - 2512) / 20);
	/* 5 GHz channels 0 - 200 */
	if ( freq >= 5000 && freq <= 6000 )
		return (freq - 5000) / 5;
	/* Undefined */
	return 0;
}

Note that AFAIK, the 5GHz WLAN channels start at 34 (5.17 GHz)
(but I am not sure) and I don't know the top limit (except that
it is <= 6GHz). Maybe somebody can shed light on this.
If there is a clear definition, that should be reflected int the code.
And something similar for channel_to_freq.
Apparently Japan is doing something in the 10GHz band -
will have to look for details.

Margit
