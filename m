From: Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>
Subject: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Thu, 5 Jan 2017 12:02:19 +0100
Message-ID: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f172.google.com ([209.85.210.172]:35600 "EHLO
        mail-wj0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967508AbdAELCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 06:02:23 -0500
Received: by mail-wj0-f172.google.com with SMTP id i20so31791004wjn.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 03:02:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I am running a single wlan0 interface in managed mode (no aliases, no 
other wireless interfaces).
The association with the AP still hasn't happened.

I noticed that if trying to change the frequency to one of the valid 
values, the driver returns EBUSY.

The call stack is
cfg80211_wext_siwfreq
-->cfg80211_mgd_wext_siwfreq
--->cfg80211_set_monitor_channel (notice call to set 'monitor' channel 
in managed mode)
----> fails with EBUSY

Is therefore the expected behavior to fail under the above circumstances 
(managed mode && single wlan0 interface && no association)?
And if it is, please could you clarify when would it be valid to change 
the frequency in managed mode?

many thanks in advance for the help,
Jorge
