From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Fri, 04 Mar 2005 17:21:22 -0500
Message-ID: <4228DF62.4000205@pobox.com>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, akpm@osdl.org,
        davem@davemloft.net, netdev@oss.sgi.com
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050304221014.GJ3327@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Fri, Mar 04, 2005 at 12:33:19PM -0500, Jeff Garzik wrote:
> 
>>akpm@osdl.org wrote:
>>
>>>From: Adrian Bunk <bunk@stusta.de>
>>>
>>>Some of the options that needlessly wrote in their help text which options
>>>they do select (patch already sent) didn't obey the most important rule of
>>>select
>>>
>>> If you select something, you have to ensure that the dependencies
>>> of what you do select are fulfilled.
>>
>>>diff -puN net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects 
>>>net/ieee80211/Kconfig
>>>--- 25/net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects 2005-02-28 
>>>14:49:54.000000000 -0800
>>>+++ 25-akpm/net/ieee80211/Kconfig	2005-02-28 14:49:54.000000000 -0800
>>>@@ -44,6 +44,7 @@ config IEEE80211_CRYPT_WEP
>>>config IEEE80211_CRYPT_CCMP
>>>	tristate "IEEE 802.11i CCMP support"
>>>	depends on IEEE80211
>>>+	select CRYPTO
>>>	select CRYPTO_AES
>>>	---help---
>>>	Include software based cipher suites in support of IEEE 802.11i 
>>>@@ -56,6 +57,7 @@ config IEEE80211_CRYPT_CCMP
>>>config IEEE80211_CRYPT_TKIP
>>>	tristate "IEEE 802.11i TKIP encryption"
>>>	depends on IEEE80211
>>>+	select CRYPTO
>>>	select CRYPTO_MICHAEL_MIC
>>>	---help---
>>
>>
>>You are resending the old patch that is incorrect.  We don't need 
>>multiple selects, CRYPTO_AES and CRYPTO_MICHAEL_MIC should pull things in.
> 
> 
> As I already said, this implies that options like CRYPTO_AES and 
> CRYPTO_MICHAEL_MIC can no longer depend on CRYPTO.

No.  Because CRYPTO_AES and CRYPTO_MICHAEL_MIC __obviously__ depend on 
CRYPTO, it should select CRYPTO automatically given the existing entries.

Otherwise, we must start specifying dependency chains in every damn 
Kconfig entry, which is completely illogical and a maintenance nightmare.

	Jeff
