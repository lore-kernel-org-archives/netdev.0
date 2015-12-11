From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Fri, 11 Dec 2015 15:38:49 +0100
Message-ID: <1449844729.2324.15.camel@sipsolutions.net>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Emmanuel Grumbach <egrumbach@gmail.com>,
	Stefan Lippers-Hollmann <s.l-h@gmx.de>
To: Dave Young <dyoung@redhat.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-11-15 at 15:31 +0800, Dave Young wrote:
> cfg80211 module prints a lot of messages like below. Actually
> printing once is acceptable but sometimes it will print again and
> again, it looks very annoying. It is better to change these detail
> messages to debugging only.
> 

Despite the objections, I've applied this patch now.

I've made one change: keeping the alpha2 (e.g. "US") printed in some of
the pr_err() cases in this file.
I also got rid of CONFIG_CFG80211_REG_DEBUG in a separate patch.

I somewhat agree with the objections, but if the kernel is with
CONFIG_DYNAMIC_DEBUG then it's really simple to get the messages back
by enabling them for this file.

Where the messages were used as an indication of something having gone
awry at a different level (e.g. mac80211 disconnect) I don't really
quite agree - that then perhaps should have a more explicit (and less
noisy) message.

I also agree that the regulatory code is quite opaque, and the way it
arrives at certain conclusions is not always obvious. These messages
don't help all that much though since they don't contain the actual
input to the decisions. I think for that, we'd be much better served
with some kind of tracepoint or so that records all the information.

johannes
