From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 17:26:55 -0400
Message-ID: <87h8upeesg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com> <20171023211109.GA23689@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023211109.GA23689@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Oct 23, 2017 at 02:17:29PM -0400, Vivien Didelot wrote:
>> DSA has several bitmaps to store the type of ports: cpu_port_mask,
>> dsa_port_mask and enabled_port_mask. But the code is inconsistently
>> unmasking them.
>> 
>> The legacy code tries to unmask cpu_port_mask and dsa_port_mask but
>> skips enabled_port_mask.
>> 
>> The new bindings unmasks cpu_port_mask and enabled_port_mask but skips
>> dsa_port_mask.
>> 
>> In fact there is no need to unmask them because we are in the error
>> path, and they won't be used after. Instead of fixing the unmasking,
>> simply remove them.
>
> I'm not looked at the code, travelling and don't have time.

heu, ok.

> What happens if the failure is -PROBE_DEFERRED, and it tried again
> later. Will these masks be set back to 0? Or will they retain the old
> values? I think there is supposed to be symmetry here, so that we undo
> what we did, and so the next time we try again, we start from a good
> state.

The type of a port is a static information parsed either from device
tree or from platform data. Thus there is no symmetry needed here.

The fact that the unmasking of these bitmaps is currently erroneous also
shows that it is unnecessary.


Thanks,

        Vivien
