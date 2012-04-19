From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: net-next iwlwifi breaks compile - was Re: pull request: wireless-next
 2012-04-18
Date: Thu, 19 Apr 2012 06:49:59 +0200
Message-ID: <4F8F9977.9040703@hartkopp.net>
References: <20120418190521.GB2436@tuxdriver.com> <20120418.153653.2130740499995307564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120418.153653.2130740499995307564.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18.04.2012 21:36, David Miller wrote:

> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Wed, 18 Apr 2012 15:05:22 -0400
> 
>> Another batch of wireless updates intended for 3.5...
>>
>> Highlights include some wl12xx refactoring, NFC HCI and SHDLC updates,
>> an ath6kl pull, some mesh updates, and the usual updates to iwlwifi,
>> ath9k, brcm80211, mwifiex, libertas, and other drivers.
>>
>> Please let me know if there are problems!
> 
> Also pulled, thanks a lot.


Commit "iwlwifi: move scan related declarations out of iwl-core.h"

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=8fb96d6e176cbf0a97b2391fa1fa09e608ee86f8

breaks the compile when CONFIG_IWLWIFI_DEBUGFS is not set, see:

  CC [M]  drivers/net/wireless/iwlwifi/iwl-agn-tt.o
In file included from drivers/net/wireless/iwlwifi/iwl-agn-tt.c:40:0:
drivers/net/wireless/iwlwifi/iwl-core.h:97:19: error: static declaration of 'iwl_alloc_traffic_mem' follows non-static declaration
drivers/net/wireless/iwlwifi/iwl-agn.h:513:5: note: previous declaration of 'iwl_alloc_traffic_mem' was here
make[4]: *** [drivers/net/wireless/iwlwifi/iwl-agn-tt.o] Error 1
make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
make: *** Waiting for unfinished jobs....

Please check these kind of source reorganizations with different CONFIG settings too.

Regards,
Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
