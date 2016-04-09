From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCHv3 net-next 5/6] bridge: a netlink notification
 should be sent when those attributes are changed by br_sysfs_if
Date: Sat, 9 Apr 2016 14:45:24 +0200
Message-ID: <5708F964.1090407@cumulusnetworks.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
	<6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
	<6197a35a2eb6df2caf90edcbf1b49da12077f659.1460131308.git.lucien.xin@gmail.com>
	<8c14a891d0a8bcea071d4e5305776a5c5cd9fd17.1460131308.git.lucien.xin@gmail.com>
	<1dd5e14c7f042753a4d70b585de407a4e388262a.1460131308.git.lucien.xin@gmail.com>
	<8c87a70b3c214f90b7345edb68536429fdaad096.1460131308.git.lucien.xin@gmail.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>, network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <8c87a70b3c214f90b7345edb68536429fdaad096.1460131308.git.lucien.xin@gmail.com>
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

On 04/08/2016 06:03 PM, Xin Long wrote:
> Now when we change the attributes of bridge or br_port by netlink,
> a relevant netlink notification will be sent, but if we change them
> by ioctl or sysfs, no notification will be sent.
> 
> We should ensure that whenever those attributes change internally or from
> sysfs/ioctl, that a netlink notification is sent out to listeners.
> 
> Also, NetworkManager will use this in the future to listen for out-of-band
> bridge master attribute updates and incorporate them into the runtime
> configuration.
> 
> This patch is used for br_sysfs_if, and we also move br_ifinfo_notify out
> of store_flag.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_sysfs_if.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 

Note: there's a slight behaviour change, before if the flags were the same
a notification wouldn't be sent, now it would. Anyway I don't see a problem
as this is true for other attributes which are set to the same value.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
