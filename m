From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: Re: [ldv-project] [net] rtl8188ee: a potential race condition
Date: Fri, 24 Jun 2016 19:47:21 +0530
Message-ID: <576D40F1.9040009@oracle.com>
References: <575A788C.5020509@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Pavel Andrianov <andrianov@ispras.ru>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46027 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbcFXOR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 10:17:57 -0400
In-Reply-To: <575A788C.5020509@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Friday 10 June 2016 01:51 PM, Pavel Andrianov wrote:
> Hi!
> 
> There is a potential data race in drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rtl8188ee.ko.
> 
> In the function rtl88ee_gpio_radio_on_off_checking the flag ppsc->rfchange_inprogress is set with a spinlock protection. In the function rtl_ps_set_rf_state the flag is read also under a spinlock. But the function rtl88e_dm_watchdog read it without any locks. As a result rtl88e_dm_watchdog may execute the succeeding code while changing (with the flag rfchange_inprogress == true). I do not exactly determine the consequences, but likely they are not good if there exists such check. Could anybody more confident confirm this?
> 
> The function rtl_ps_set_rf_state is always called with its parameter [protect_or_not == false]. Is this flag really necessary, if the value 'true' is never used? The function is also set the flag ppsc->rfchange_inprogress and may affect the rtl88e_dm_watchdog as in the previous case.

I think the patch was sent sometime ago for removing the parameter. But I am not sure why it's not applied.
May be Larry can have better idea about this.

Here, is link to the patch: http://linux-wireless.vger.kernel.narkive.com/mu4t9xxr/patch-3-4-rtlwifi-rtl8192cu-remove-unused-parameter

-- 
Vaishali
