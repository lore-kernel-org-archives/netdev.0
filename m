From: "PaX Team" <pageexec@freemail.hu>
Subject: question about potential integer truncation in mwifiex_set_wapi_ie and mwifiex_set_wps_ie
Date: Tue, 29 Sep 2015 17:21:28 +0200
Message-ID: <560AAC78.14106.6193CAA9@pageexec.freemail.hu>
Reply-To: pageexec@freemail.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	re.emese@gmail.com, spender@grsecurity.net
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r00tworld.com ([212.85.137.150]:51740 "EHLO r00tworld.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935119AbbI2Pd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 11:33:28 -0400
Content-description: Mail message body
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi all,

in drivers/net/wireless/mwifiex/sta_ioctl.c the following functions

	mwifiex_set_wpa_ie_helper
	mwifiex_set_wapi_ie
	mwifiex_set_wps_ie

can truncate the incoming ie_len argument from u16 to u8 when it gets
stored in mwifiex_private.wpa_ie_len, mwifiex_private.wapi_ie_len and
mwifiex_private.wps_ie_len, respectively. based on some light code
reading it seems a length value of 256 is valid (IEEE_MAX_IE_SIZE and
MWIFIEX_MAX_VSIE_LEN seem to limit it) and thus would get truncated
to 0 when stored in those u8 fields. the question is whether this is
intentional or a bug somewhere.

FTR, this issue was detected with the upcoming version of the size overflow
plugin we have in PaX/grsecurity and there're a handful of similar cases in
the tree where potentially unwanted or unnecessary integer truncations occur,
this being one of these. any opinion/help is welcome!

cheers,
  PaX Team
