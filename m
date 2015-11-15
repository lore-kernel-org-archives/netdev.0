From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Sun, 15 Nov 2015 09:38:54 -0800
Message-ID: <1447609134.6012.15.camel@perches.com>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, johannes@sipsolutions.net
To: Dave Young <dyoung@redhat.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-11-15 at 15:31 +0800, Dave Young wrote:
> cfg80211 module prints a lot of messages like below. Actually printing
> once is acceptable but sometimes it will print again and again, it looks
> very annoying. It is better to change these detail messages to debugging
> only.

So maybe add some wrapper that does a pr_info then
a pr_debug for the second and subsequent uses like:

#define pr_info_once_then_debug(fmt, ...)			\
({								\
	static bool __print_once __read_mostly;			\
								\
	if (!__print_once) {					\
		__print_once = true;				\
		pr_info(fmt, ##__VA_ARGS__);			\
	} else {						\
		pr_debug(fmt, ##__VA_ARGS__);			\
	}							\
})
