From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: improve nl80211_parse_mesh_config type checking
Date: Tue, 28 Jun 2016 12:49:42 +0200
Message-ID: <1467110982.2493.10.camel@sipsolutions.net>
References: <20160615203012.3544326-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615203012.3544326-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-06-15 at 22:29 +0200, Arnd Bergmann wrote:
> When building a kernel with W=1, the nl80211.c file causes a number
> of
> warnings, all about the same problem:
> 
> net/wireless/nl80211.c: In function 'nl80211_parse_mesh_config':
> net/wireless/nl80211.c:5287:103: error: comparison is always false
> due to limited range of data type [-Werror=type-limits]
> net/wireless/nl80211.c:5290:96: error: comparison is always false due
> to limited range of data type [-Werror=type-limits]
> net/wireless/nl80211.c:5293:124: error: comparison is always false
> due to limited range of data type [-Werror=type-limits]
> net/wireless/nl80211.c:5295:148: error: comparison is always false
> due to limited range of data type [-Werror=type-limits]
> net/wireless/nl80211.c:5298:106: error: comparison is always false
> due to limited range of data type [-Werror=type-limits]
> net/wireless/nl80211.c:5305:116: error: comparison is always false
> due to limited range of data type [-Werror=type-limits]
> 
> The problem is that gcc does not notice that the check is generate
> by a macro, so it complains about comparing an unsigned type against
> 0.
> 
> I've tried to come up with a way to rephrase that code in a way that
> avoids the warnings and otherwise improves the code as well.
> 
> This uses a set of new helper functions that perform the range
> checking,
> and should provide slightly better type safety than the older patch,
> at the expense of adding 44 lines to the code. Binary code size is
> basically unchanged though (20 bytes added to 126561 bytes .text).
> 
Applied.

johannes
