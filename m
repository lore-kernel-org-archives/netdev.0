From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] macvlan: Support interface operstate properly
Date: Wed, 6 Apr 2016 23:03:38 +0200
Message-ID: <570579AA.6050400@cumulusnetworks.com>
References: <1459974608-25324-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Debabrata Banerjee <dbanerje@akamai.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36853 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcDFVDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 17:03:41 -0400
Received: by mail-wm0-f47.google.com with SMTP id v188so36037507wme.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 14:03:40 -0700 (PDT)
In-Reply-To: <1459974608-25324-1-git-send-email-dbanerje@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2016 10:30 PM, Debabrata Banerjee wrote:
> Set appropriate macvlan interface status based on lower device and our
> status. Can be up, down, or lowerlayerdown.
> 
> Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
> 

May I ask what is exactly that you're fixing here ? I recently had to make macvlan's
operstates more accurate and I haven't experienced any wrong behaviour since commit
de7d244d0a35 ("macvlan: make operstate and carrier more accurate").
Also it's the linkwatch's job to take care for the proper operstate, we can use
netif_stacked_transfer_operstate to help it, but I don't think directly setting
operstate is a good idea.

One more thing - you cannot use netdev_state_change() under the write_lock as it
may sleep.
