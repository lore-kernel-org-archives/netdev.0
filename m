From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Wed, 30 Aug 2017 09:40:36 +0200
Message-ID: <20170830074036.GA1903@nanopsycho>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828.213837.1354872205076475221.davem@davemloft.net>
 <20170829062931.GB1977@nanopsycho.orion>
 <87ziai4b99.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com, andrew@lunn.ch, privat@egil-hjelmeland.no,
        john@phrozen.org, Woojung.Huh@microchip.com,
        sean.wang@mediatek.com, nikita.yoush@cogentembedded.com,
        cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ziai4b99.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Aug 29, 2017 at 05:57:54PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi David, Jiri,
>
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> Tue, Aug 29, 2017 at 06:38:37AM CEST, davem@davemloft.net wrote:
>>>From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>>Date: Mon, 28 Aug 2017 15:17:38 -0400
>>>
>>>> This patch series adds a generic debugfs interface for the DSA
>>>> framework, so that all switch devices benefit from it, e.g. Marvell,
>>>> Broadcom, Microchip or any other DSA driver.
>>>
>>>I've been thinking this over and I agree with the feedback given that
>>>debugfs really isn't appropriate for this.
>>>
>>>Please create a DSA device class, and hang these values under
>>>appropriate sysfs device nodes that can be easily found via
>>>/sys/class/dsa/ just as easily as they would be /sys/kernel/debug/dsa/
>>>
>>>You really intend these values to be consistent across DSA devices,
>>>and you don't intend to go willy-nilly changig these exported values
>>>arbitrarily over time.  That's what debugfs is for, throw-away
>>>stuff.
>>>
>>>So please make these proper device sysfs attributes rather than
>>>debugfs.
>>
>> As I wrote, I believe that there is a big overlap with devlink and its
>> dpipe subset. I think that primary we should focus on extending whatever
>> is needed for dsa there. The iface should be generic for all drivers,
>> not only dsa. dsa-specific sysfs attributes should be last-resort solution,
>> I believe we can avoid them.
>
>Please note that this interface is only meant to provide a _debug_ and
>_development_ interface to DSA users. It is enableable at compile time
>and can be ditched anytime we want, in contrary to other interfaces
>which cannot be broken or changed because they are part of the ABI.
>
>I see sysfs as a script-friendly way to access and configure kernel
>structures, so I agree with Jiri that it doesn't seem appropriate.
>
>Extending devlink is a good option for long term, but it'll take a bit
>of time to extend data structures and not duplicate stats and regs
>accesses for ports which have a net device attached to it or not.
>
>In the meantime, I didn't find anything more useful and easier to debug
>a switch fabric than dumping side-by-side stats of all ports part of the
>data plane, for example like this:

So in the meantime, if you need some quick ugly think, you can always
have it out of the tree. Sorry but these are just excuses :/


>
>    # watch -n1 pr -mt {switch0/port5,switch0/port6,switch1/port5,switch1/port3}/stats
>
>where ports 5 and 6 of both switches are DSA/CPU ports (without net
>devices attached to them) and port3 is a user port. This way one can
>easily see where and why packets get dropped.
>
>We could keep this interface and simply ditch net/dsa/debugfs.c when a
>convenient devlink alternative is in place.
>
>
>Thanks,
>
>        Vivien
