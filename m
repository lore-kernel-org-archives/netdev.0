From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH net-next] net: dsa: select NET_SWITCHDEV
Date: Mon, 9 Jan 2017 08:47:31 -0800
Message-ID: <a8f38ecb-f85e-4fa4-5bd6-4511cdfe3ab0@infradead.org>
References: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
 <ae5c2999-98a3-1b88-dd1d-970d958f6d7a@gmail.com>
 <336a46c0-705a-9cf0-1a0d-447af28893bb@infradead.org>
 <87d1fwurbw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1fwurbw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/17 08:32, Vivien Didelot wrote:
> Hi Randy,
> 
> Randy Dunlap <rdunlap@infradead.org> writes:
> 
>> On 01/08/17 17:18, Florian Fainelli wrote:
>>> On 01/08/2017 03:17 PM, Vivien Didelot wrote:
>>>> DSA wraps SWITCHDEV, thus select it instead of depending on it.
>>>>
>>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>>
>>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>>>
>>
>> but when CONFIG_INET is not enabled, the patch causes this warning:
>>
>> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
> 
> Thanks for spotting that! Would that be enough to change this first?
> 
>     diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
>     index 675acbf1502d..c7263b70e72b 100644
>     --- a/net/dsa/Kconfig
>     +++ b/net/dsa/Kconfig
>     @@ -1,6 +1,6 @@
>     config HAVE_NET_DSA
>             def_bool y
>     -       depends on NETDEVICES && !S390
>     +       depends on INET && NETDEVICES && !S390
> 
>     # Drivers must select NET_DSA and the appropriate tagging format

Yes, thanks.

Tested-by: Randy Dunlap <rdunlap@infradead.org>


-- 
~Randy
