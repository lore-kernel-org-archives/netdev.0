From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 08:55:00 +0200
Message-ID: <53CCB944.8090709@nod.at>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
 <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Shao <huishao@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>,
 "David S. Miller" <davem@davemloft.net>
To: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Yie,

Am 21.07.2014 04:44, schrieb Yue Zhang (OSTC DEV):
>> From: Richard Weinberger [mailto:richard.weinberger@gmail.com]
>> Why 10? Is this a random number which works by accident for ifplugd?
>> What about other networking implementations, is 10 also ok for them?
>> --
>> Thanks,
>> //richard
> 
> Hi, Richard
> 
> I checked ifplugd's code. The deferring time is 5 seconds. That's how  comes 
> the "10s". I agree with you this is a magic number and should be avoid. However, 
> this is the only feasible solution right now. If there is a better solution, I will be 
> glad to switch to it.
> 
> I tested the fix in Redhat, Ubuntu and SUSE and it works in all of them.

The problem I see is that there is no good way to trigger a DHCP renew from
a network device drivers. You're on the wrong layer.
10 seconds may work but this is IMHO a hack which can easily break.
There are also more networking implementations than ifplugd.
Specially the systemd implementation looks promising.

Can't you propagate the RNDIS_STATUS_NETWORK_CHANGE event to userspace?
IIRC on HyperV guests already have a guest daemon. Let the daemon handle
the event such that distros can install their own hooks...

Thanks,
//richard
