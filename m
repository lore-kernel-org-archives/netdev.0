From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Rate limiting AP bandwidth change messages in ieee80211_config_bw?
Date: Wed, 30 Sep 2015 13:02:53 -0400
Message-ID: <CA+5PVA4yaLG2NtJ_Bg5-BQzR-Wa5ABxPb-cLxF7bjSsf-P1_5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: drago01 <drago01@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36535 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbbI3RCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 13:02:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

We've seen a handful of reports that seem to have verbose output from
the ieee80211_config_bw function in net/mac80211/mlme.c.  It looks
similar to this:

[   66.578652] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   68.522437] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   69.548353] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   70.568677] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   71.489416] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   72.512917] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   73.535866] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   81.777530] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   82.540576] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   94.513467] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   95.634855] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   97.474767] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[   98.498036] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[   99.520472] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[  100.551344] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)
[  101.571100] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 1 (2437/0 MHz)
[  102.490708] wlp3s0: AP xx:xx:xx:xx:xx changed bandwidth, new config
is 2437 MHz, width 2 (2447/0 MHz)

Essentially, this looks like the AP is changing the bandwidth (and
only the width) every second or so.  Why it is doing this, I'm not
sure.  However, this doesn't seem to actually be an error case yet the
kernel logs are getting spammed with this message.

I'm wondering if we could either change this message to use sdata_dbg
instead of sdata_info, or if we could possibly ratelimit it somehow.
I'd be happy to come up with a patch for either, but I wanted to get
your feedback on it before I started.  Do you have any objections or
preference?

josh
