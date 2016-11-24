From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [RFC net-next 1/3] net: bridge: Allow bridge master
 device to configure switch CPU port
Date: Thu, 24 Nov 2016 10:49:08 +0900
Message-ID: <ee14a75c-b0f5-59e5-e621-2855ec583ae6@lab.ntt.co.jp>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
	<20161121190925.14530-2-f.fainelli@gmail.com>
	<87h96zzfe6.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, andrew@lunn.ch, bridge@lists.linux-foundation.org,
	jiri@mellanox.com, davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <87h96zzfe6.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
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

On 2016/11/23 0:46, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> bridge vlan add vid 2 dev br0 self
>> 	-> CPU port gets programmed
>> bridge vlan add vid 2 dev port0
>> 	-> port0 (switch port 0) gets programmed
> 
> Although this is not specific to this patch, I'd like to point out that
> this seems not to be the behavior bridge expects.
> 
> The bridge manpage says:
> 
>     bridge vlan add - add a new vlan filter entry
>     ...
> 
>        self   the vlan is configured on the specified physical device.
>               Required if the device is the bridge device.
> 
>        master the vlan is configured on the software bridge (default).
> 
> So if I'm not mistaken, the switch chip must be programmed only when the
> bridge command is called with the "self" attribute. Without it, only
> software configuration must be made, like what happens when the driver
> returns -EOPNOTSUPP.
> 
> Currently, both commands below program the hardware:
> 
>     # bridge vlan add vid 2 dev port0 [master]
>     # bridge vlan add vid 2 dev port0 [master] self

Actually this is intended behavior, which keeps backward compatibility.
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=7f1095394918c7058ff81c96c3bab3a897e97a9d

Thanks,
Toshiaki Makita
