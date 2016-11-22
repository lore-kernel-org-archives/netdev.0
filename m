From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port
	configuration
Date: Tue, 22 Nov 2016 10:29:59 -0500
Message-ID: <87k2bvzg5k.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: idosch@mellanox.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>,
	bridge@lists.linux-foundation.org, jiri@mellanox.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161121190925.14530-1-f.fainelli@gmail.com>
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

> This patch series allows using the bridge master interface to configure
> an Ethernet switch port's CPU/management port with different VLAN attributes than
> those of the bridge downstream ports/members.
>
> Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
> tested this with b53 and a mockup DSA driver.

Patchset looks fine to me overall. I'm cooking a patch similar to 3/3
for mv88e6xxx to put on top of this patchset.

Minor comments in individual patchs will follow.

> Open questions:
>
> - if we have more than one bridge on top of a physical switch, the driver
>   should keep track of that and verify that we are not going to change
>   the CPU port VLAN attributes in a way that results in incompatible settings
>   to be applied

In mv88e6xxx, mv88e6xxx_port_check_hw_vlan() does that. It needs a small
adjustment though.

> - if the default behavior is to have all VLANs associated with the CPU port
>   be ingressing/egressing tagged to the CPU, is this really useful?

I have no strong opinion on this. Intuitively I'd expect the CPU port to
be excluded until I add it myself, but I didn't think much about it.

Thanks,

        Vivien
