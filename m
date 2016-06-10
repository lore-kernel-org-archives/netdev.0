From: Pavel Andrianov <andrianov@ispras.ru>
Subject: [ldv-project] [net] rtl8188ee: a potential race condition
Date: Fri, 10 Jun 2016 12:21:32 +0400
Message-ID: <575A788C.5020509@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>,
	ldv-project@linuxtesting.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential data race in 
drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rtl8188ee.ko.

In the function rtl88ee_gpio_radio_on_off_checking the flag 
ppsc->rfchange_inprogress is set with a spinlock protection. In the 
function rtl_ps_set_rf_state the flag is read also under a spinlock. But 
the function rtl88e_dm_watchdog read it without any locks. As a result 
rtl88e_dm_watchdog may execute the succeeding code while changing (with 
the flag rfchange_inprogress == true). I do not exactly determine the 
consequences, but likely they are not good if there exists such check. 
Could anybody more confident confirm this?

The function rtl_ps_set_rf_state is always called with its parameter 
[protect_or_not == false]. Is this flag really necessary, if the value 
'true' is never used? The function is also set the flag 
ppsc->rfchange_inprogress and may affect the rtl88e_dm_watchdog as in 
the previous case.

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
