From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon, 2 Jun 2014 10:21:43 -0700
Message-ID: <CAGVrzcbzH2Q5Rq942hyqzGzUucBGkF+Hrxh2uZkyO-ePMQ2Hyw@mail.gmail.com>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>
 <20140602143557.GA2925@minipsycho.orion> <20140602150150.GF6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Michal Privoznik <mprivozn@redhat.com>,
	David Miller <davem@davemloft.net>,
	Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602150150.GF6295@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-06-02 8:01 GMT-07:00 Veaceslav Falico <vfalico@redhat.com>:
> On Mon, Jun 02, 2014 at 04:35:57PM +0200, Jiri Pirko wrote:
>>
>> Mon, Jun 02, 2014 at 04:25:15PM CEST, mprivozn@redhat.com wrote:
>>>
>>> The link speed is available at /sys/class/net/$nic/speed.
>>> However, the speed is printed in unsigned integer format. This
>>> makes userspace applications read an incorrect value (which
>>> moreover changes through several architectures) while in fact
>>> '-1' should be reported.
>>>
>>> Before the change:
>>>  # cat /sys/class/net/eth0/speed
>>>  4294967295
>>>
>>> After the change:
>>>  # cat /sys/class/net/eth0/speed
>>>  -1
>>>
>>> Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
>>> ---
>>> net/core/net-sysfs.c | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>>> index 1cac29e..99afdea 100644
>>> --- a/net/core/net-sysfs.c
>>> +++ b/net/core/net-sysfs.c
>>> @@ -173,7 +173,7 @@ static ssize_t speed_show(struct device *dev,
>>>         if (netif_running(netdev)) {
>>>                 struct ethtool_cmd cmd;
>>>                 if (!__ethtool_get_settings(netdev, &cmd))
>>> -                       ret = sprintf(buf, fmt_udec,
>>> ethtool_cmd_speed(&cmd));
>>> +                       ret = sprintf(buf, fmt_dec,
>>> ethtool_cmd_speed(&cmd));
>>
>>
>> I wonder why this should be signed. What -1 means? What driver reports
>> this?
>
>
> My first thoughts were exactly this. There is SPEED_UNKOWN (along with
> _10, _100, _1000 etc.) that's -1, and quite a few drivers use it/set it.
>
> I wonder, though, if we should document it or just output "Unknown" instead
> of -1.

I would document the special "Unkown" value in
Documentation/ABI/testing/sysfs-class-net and update speed_show() to
handle it. -1 is confusing for anyone to realize what this means.

>
>>
>>>         }
>>>         rtnl_unlock();
>>>         return ret;
>>> --
>>> 2.0.0
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
>
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
