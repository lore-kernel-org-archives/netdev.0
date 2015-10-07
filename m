From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: allow adding of fdb
 entries pointing to the bridge device
Date: Wed, 7 Oct 2015 13:40:05 +0200
Message-ID: <56150495.2070909@cumulusnetworks.com>
References: <1444147589-11153-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1444147589-11153-1-git-send-email-roopa@cumulusnetworks.com>
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

On 10/06/2015 06:06 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch enables adding of fdb entries pointing to the bridge device.
> This can be used to propagate mac address of vlan interfaces
> configured on top of the vlan filtering bridge.
> 
> Before:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
> RTNETLINK answers: Invalid argument
> 
> After:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/bridge/br_fdb.c | 110 ++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 85 insertions(+), 25 deletions(-)
> 

Ugh my bad, Dave please don't apply this version, there're still a few rough
edges we need to take care of. Now that bridge's vlan_group can be used in these
functions the vlans should be checked for context-only, i.e. br_vlan_should_use()
and also when a port vlan is deleted its fdb entries are flushed, but that is not
done for the bridge since it wasn't possible to add them like this. So v3 coming
soon to your neighborhood! :-)

Thanks,
 Nik
