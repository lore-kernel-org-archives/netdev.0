From: Adrien Schildknecht <adrien+dev@schischi.me>
Subject: [PATCH] iwlwifi: out-of-bounds access in iwl_init_sband_channels
Date: Fri, 14 Aug 2015 02:35:32 +0200
Message-ID: <1439512532-7901-1-git-send-email-adrien+dev@schischi.me>
Cc: ilw@linux.intel.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35333 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbHNAgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 20:36:04 -0400
Received: by wicne3 with SMTP id ne3so2776456wic.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 17:36:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both loops of this function compare data from the 'chan' array and then
check if the index is valid.

The 2 conditions should be inverted to avoid an out-of-bounds access.

Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
---
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c b/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
index 21302b6..acc3d18 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
@@ -713,12 +713,12 @@ int iwl_init_sband_channels(struct iwl_nvm_data *data,
 	struct ieee80211_channel *chan = &data->channels[0];
 	int n = 0, idx = 0;
 
-	while (chan->band != band && idx < n_channels)
+	while (idx < n_channels && chan->band != band)
 		chan = &data->channels[++idx];
 
 	sband->channels = &data->channels[idx];
 
-	while (chan->band == band && idx < n_channels) {
+	while (idx < n_channels && chan->band == band) {
 		chan = &data->channels[++idx];
 		n++;
 	}
-- 
2.5.0
