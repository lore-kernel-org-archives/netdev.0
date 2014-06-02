From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon, 2 Jun 2014 17:01:50 +0200
Message-ID: <20140602150150.GF6295@redhat.com>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>
 <20140602143557.GA2925@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michal Privoznik <mprivozn@redhat.com>, davem@davemloft.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140602143557.GA2925@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 02, 2014 at 04:35:57PM +0200, Jiri Pirko wrote:
>Mon, Jun 02, 2014 at 04:25:15PM CEST, mprivozn@redhat.com wrote:
>>The link speed is available at /sys/class/net/$nic/speed.
>>However, the speed is printed in unsigned integer format. This
>>makes userspace applications read an incorrect value (which
>>moreover changes through several architectures) while in fact
>>'-1' should be reported.
>>
>>Before the change:
>>  # cat /sys/class/net/eth0/speed
>>  4294967295
>>
>>After the change:
>>  # cat /sys/class/net/eth0/speed
>>  -1
>>
>>Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
>>---
>> net/core/net-sysfs.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>>index 1cac29e..99afdea 100644
>>--- a/net/core/net-sysfs.c
>>+++ b/net/core/net-sysfs.c
>>@@ -173,7 +173,7 @@ static ssize_t speed_show(struct device *dev,
>> 	if (netif_running(netdev)) {
>> 		struct ethtool_cmd cmd;
>> 		if (!__ethtool_get_settings(netdev, &cmd))
>>-			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
>>+			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
>
>I wonder why this should be signed. What -1 means? What driver reports
>this?

My first thoughts were exactly this. There is SPEED_UNKOWN (along with
_10, _100, _1000 etc.) that's -1, and quite a few drivers use it/set it.

I wonder, though, if we should document it or just output "Unknown" instead
of -1.

>
>> 	}
>> 	rtnl_unlock();
>> 	return ret;
>>--
>>2.0.0
>>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
