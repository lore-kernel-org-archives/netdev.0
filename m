From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC -next 2/2] virtio_net: Read and use the advised MTU
Date: Thu, 10 Mar 2016 21:56:50 +0300
Message-ID: <56E1C372.60204@cogentembedded.com>
References: <1457620092-24170-1-git-send-email-aconole@redhat.com>
	<1457620092-24170-3-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Aaron Conole <aconole@redhat.com>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1457620092-24170-3-git-send-email-aconole@redhat.com>
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

Hello.

On 03/10/2016 05:28 PM, Aaron Conole wrote:

> This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
> exists, read the advised MTU and use it.
>
> No proper error handling is provided for the case where a user changes the
> negotiated MTU. A future commit will add proper error handling. Instead, a
> warning is emitted if the guest changes the device MTU after previously being
> given advice.
>
> Signed-off-by: Aaron Conole <aconole@redhat.com>
> ---
>   drivers/net/virtio_net.c | 15 ++++++++++++++-
>   1 file changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 767ab11..7175563 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
[...]
> @@ -1390,8 +1391,12 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
>
>   static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>   {
> +	struct virtnet_info *vi = netdev_priv(dev);
>   	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
>   		return -EINVAL;
> +	if (vi->negotiated_mtu == true) {
> +		pr_warn("changing mtu from negotiated mtu.");
> +	}

    {} not needed, see Documentation/CodingStyle.

[...]

MBR, Sergei
