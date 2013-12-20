From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 02/11] staging: r8188eu: Remove wrapper around spin_lock_bh
Date: Fri, 20 Dec 2013 10:36:09 -0600
Message-ID: <52B471F9.9080400@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net> <1387514323-4486-3-git-send-email-Larry.Finger@lwfinger.net> <20131220071408.GK28413@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34751 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab3LTQgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:36:14 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2731073pde.14
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:36:14 -0800 (PST)
In-Reply-To: <20131220071408.GK28413@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 01:14 AM, Dan Carpenter wrote:
> On Thu, Dec 19, 2013 at 10:38:34PM -0600, Larry Finger wrote:
>> Some comment lines that mentioned spin_lock_bh() are also removed.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> @@ -1509,10 +1509,6 @@ _func_enter_;
>>
>>   	rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);
>>
>> -	_enter_critical_bh(&pmlmepriv->lock, &irqL);
>> -	_exit_critical_bh(&pmlmepriv->lock, &irqL);
>> -
>> -
>>   _func_exit_;
>>   }
>
> This is a functionality change that slipped in.  This is like
> spin_unlock_wait() where you want to wait until the lock is released.
>
> In this code it's probably unintended?  But don't put these things into
> a patch without mentioning it.

Dan,

Yes, I should have mentioned that I was removing a pointless lock/unlock 
sequence. Upon further checking, I see that the original driver I received from 
Realtek did have a reason for locking there, but a line was dropped from the 
code. This section should contain the following:

diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c 
b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 402fd21..b376d09 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -1505,6 +1505,9 @@ _func_enter_;

         rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);

+        spin_lock_bh(&pmlmepriv->lock);
+        rtw_sitesurvey_cmd(struct adapter padapter, &ssid, 1, NULL, 0);
+        spin_unlock_bh(&pmlmepriv->lock);
  _func_exit_;
  }


Thanks for reading the patches.

@Greg: Is it OK if I leave the previous patch alone and submit the above as a 
separate change?

Larry
