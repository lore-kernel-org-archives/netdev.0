From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] macvlan: Introduce 'passthru' mode to takeover the underlying
 device
Date: Sat, 30 Oct 2010 13:55:25 -0700
Message-ID: <4CCC863D.2070406@us.ibm.com>
References: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com> <201010291545.17910.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <201010291545.17910.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2010 6:45 AM, Arnd Bergmann wrote:
> On Friday 29 October 2010, Sridhar Samudrala wrote:
>> With the current default 'vepa' mode, a KVM guest using virtio with
>> macvtap backend has the following limitations.
>> - cannot change/add a mac address on the guest virtio-net
> I believe this could be changed if there is a neeed, but I actually
> consider it one of the design points of macvlan that the guest
> is not able to change the mac address. With 802.1Qbg you rely on
> the switch being able to identify the guest by its MAC address,
> which the host kernel must ensure.
>
Currently the host cannot prevent a guest user from trying to change/add 
a mac address
on the guest virtio-net. From guest point of view, the request succeeds, 
but the incoming packets
are dropped siliently by the host interface.

>> - cannot create a vlan device on the guest virtio-net
> Why not? If this doesn't work, it's probably a bug!
Because the host is not aware of the guest vlan tag and the host 
external interface will filter out
incoming vlan tagged packets.

> Why does the passthru mode enable it if it doesn't work
> already?
>
passthru mode puts the host external interface in promiscuous mode which 
allows vlan tagged
packets to be received.

Even in tap/bridge mode, this works because adding an external interface 
to the bridge causes it to be
put in promiscuous mode.

Thanks
Sridhar

