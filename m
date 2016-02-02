From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] virtio_net: add ethtool support for set and get
	of settings
Date: Tue, 2 Feb 2016 13:56:16 +0100
Message-ID: <56B0A770.2030103@cumulusnetworks.com>
References: <1454417480-28672-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	virtualization@lists.linux-foundation.org, davem@davemloft.net,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1454417480-28672-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/02/2016 01:51 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch allows the user to set and retrieve speed and duplex of the
> virtio_net device via ethtool. Having this functionality is very helpful
> for simulating different environments and also enables the virtio_net
> device to participate in operations where proper speed and duplex are
> required (e.g. currently bonding lacp mode requires full duplex). Custom
> speed and duplex are not allowed, the user-supplied settings are validated
> before applying. Only full and unknown duplex are allowed to be set.
> 
> Example:
> $ ethtool eth1
> Settings for eth1:
> ...
> 	Speed: Unknown!
> 	Duplex: Unknown! (255)
> $ ethtool -s eth1 speed 1000 duplex full
> $ ethtool eth1
> Settings for eth1:
> ...
> 	Speed: 1000Mb/s
> 	Duplex: Full
> 
> Based on a patch by Roopa Prabhu.
> 
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: virtualization@lists.linux-foundation.org
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Allowed to set unknown speed/duplex if the user wants to reset them, though
> the user-space ethtool tool currently doesn't allow setting them.
> 

Since the speed can be anything maybe we should allow custom speeds after all ?
I wasn't sure about that so I added the validation.

Thanks,
 Nik
