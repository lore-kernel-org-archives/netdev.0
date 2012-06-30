From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Sat, 30 Jun 2012 15:20:06 +0200
Message-ID: <1341062406.1911.76.camel@x61.thuisdomein>
References: <1340786187.1911.24.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340786187.1911.24.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-27 at 10:36 +0200, Paul Bolle wrote:
> Every now and then, after resuming from suspend, the iwlegacy driver
> prints
>     iwl4965 0000:03:00.0: Queue 2 stuck for 2000 ms.
>     iwl4965 0000:03:00.0: On demand firmware reload
> 
> I have no idea what causes these errors. But the code currently uses
> wd_timeout in the first error. wd_timeout will generally be set at
> IL_DEF_WD_TIMEOUT (ie, 2000). Perhaps printing for how long the queue
> was actually stuck can clarify the cause of these errors.

0) It's not just after resume! I just found the following lines through
dmesg (note that it's a period that all messages in dmesg were wlan
related, for some reason):

[...]
[114649.872338] wlan0: associated
[115837.970798] wlan0: deauthenticated from [...] (Reason: 7)
[115837.993405] cfg80211: Calling CRDA to update world regulatory domain
[115838.011979] cfg80211: World regulatory domain updated:
[115838.011986] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[115838.011995] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[115838.012033] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[115838.012041] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[115838.012048] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[115838.012055] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[115838.012108] cfg80211: Calling CRDA for country: NL
[115838.022615] cfg80211: Regulatory domain changed to country: NL
[115838.022622] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[115838.022630] cfg80211:   (2402000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[115838.022637] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[115838.022644] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[115838.022651] cfg80211:   (5490000 KHz - 5710000 KHz @ 40000 KHz), (N/A, 2700 mBm)
[115840.219977] wlan0: authenticate with [...]
[115840.228865] wlan0: send auth to [...] (try 1/3)
[115840.429054] wlan0: send auth to [...] (try 2/3)
[115840.630026] wlan0: send auth to [...] (try 3/3)
[115840.831051] wlan0: authentication with [...] timed out
[115848.022336] wlan0: authenticate with [...]
[115848.022495] wlan0: direct probe to [...] (try 1/3)
[115848.223052] wlan0: direct probe to [...] (try 2/3)
[115848.424052] wlan0: direct probe to [...] (try 3/3)
[115848.625048] wlan0: authentication with [...] timed out
[115855.702461] wlan0: authenticate with [...]
[115855.702623] wlan0: direct probe to [...] (try 1/3)
[115855.903053] wlan0: direct probe to [...] (try 2/3)
[115856.104061] wlan0: direct probe to [...] (try 3/3)
[115856.305050] wlan0: authentication with [...] timed out
[115863.464067] wlan0: authenticate with [...]
[115863.464221] wlan0: direct probe to [...] (try 1/3)
[115863.665054] wlan0: direct probe to [...] (try 2/3)
[115863.866058] wlan0: direct probe to [...] (try 3/3)
[115864.067051] wlan0: authentication with [...] timed out
[115871.267216] wlan0: authenticate with [...]
[115871.267376] wlan0: send auth to [...] (try 1/3)
[115871.269191] wlan0: authenticated
[115871.279459] wlan0: associate with [...] (try 1/3)
[115871.281715] wlan0: RX AssocResp from [...] (capab=0x411 status=0 aid=2)
[115871.281723] wlan0: associated
[115871.457043] iwl4965 0000:03:00.0: Queue 2 stuck for 33487 ms.
[115871.457048] iwl4965 0000:03:00.0: On demand firmware reload
[115871.457149] ieee80211 phy0: Hardware restart was requested
[117985.197630] wlan0: deauthenticating from [...] by local choice (reason=3)
[...]

1) My guess is that I left my laptop unattended for quite some time (so
_perhaps_ generating little to no wlan traffic), and in that period
NetworkManager and friends ran into trouble re-authenticating to my
wireless router. By the time authentication succeeded it just looked
like "Queue 2" was stuck. Wild, uneducated guess, actually.

2) It's always "Queue 2" that's stuck. What does that queue do?


Paul Bolle
