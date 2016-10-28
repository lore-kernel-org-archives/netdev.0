From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: fils_aead: fix encrypt error handling
Date: Fri, 28 Oct 2016 12:58:54 +0200
Message-ID: <1477652334.4220.0.camel@sipsolutions.net>
References: <20161028102621.1881878-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jouni Malinen <jouni@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161028102621.1881878-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-28 at 12:25 +0200, Arnd Bergmann wrote:
> gcc -Wmaybe-uninitialized reports a bug in aes_siv_encryp:
> 
> net/mac80211/fils_aead.c: In function ‘aes_siv_encrypt.constprop’:
> net/mac80211/fils_aead.c:84:26: error: ‘tfm2’ may be used
> uninitialized in this function [-Werror=maybe-uninitialized]
> 
> At the time that the memory allocation fails, 'tfm2' has not been
> allocated, so we should not attempt to free it later, and we can
> simply return an error.
> 
> Fixes: 39404feee691 ("mac80211: FILS AEAD protection for station mode
> association frames")

Ahrg, how did I miss that.

Dave, I'll apply this, and send a new pull request.

johannes
