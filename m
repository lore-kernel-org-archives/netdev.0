From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC net-next 1/3] net: bridge: Allow bridge master
	device to configure switch CPU port
Date: Tue, 22 Nov 2016 10:46:25 -0500
Message-ID: <87h96zzfe6.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
	<20161121190925.14530-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: idosch@mellanox.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>,
	bridge@lists.linux-foundation.org, jiri@mellanox.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161121190925.14530-2-f.fainelli@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> bridge vlan add vid 2 dev br0 self
> 	-> CPU port gets programmed
> bridge vlan add vid 2 dev port0
> 	-> port0 (switch port 0) gets programmed

Although this is not specific to this patch, I'd like to point out that
this seems not to be the behavior bridge expects.

The bridge manpage says:

    bridge vlan add - add a new vlan filter entry
    ...

       self   the vlan is configured on the specified physical device.
              Required if the device is the bridge device.

       master the vlan is configured on the software bridge (default).

So if I'm not mistaken, the switch chip must be programmed only when the
bridge command is called with the "self" attribute. Without it, only
software configuration must be made, like what happens when the driver
returns -EOPNOTSUPP.

Currently, both commands below program the hardware:

    # bridge vlan add vid 2 dev port0 [master]
    # bridge vlan add vid 2 dev port0 [master] self

Jiri, what do you think? Is there a reason for switchdev not to be
consistent with the bridge doc, or should this be fixed?

Thanks,

        Vivien
