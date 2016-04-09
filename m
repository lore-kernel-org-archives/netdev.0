From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCHv3 net-next 0/6] bridge: support sending rntl
 info when we set attributes through sysfs/ioctl
Date: Sat, 9 Apr 2016 14:55:24 +0200
Message-ID: <5708FBBC.7000106@cumulusnetworks.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>, network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
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
> This patchset is used to support sending rntl info to user in some places,
> and ensure that whenever those attributes change internally or from sysfs,
> that a netlink notification is sent out to listeners.
> 
> It also make some adjustment in bridge sysfs so that we can implement this
> easily.
> 
> I've done some tests on this patchset, like:
> [br_sysfs]
>   1. change all the attribute values of br or brif:
>   $ echo $value > /sys/class/net/br0/bridge/{*}
>   $ echo $value > /sys/class/net/br0/brif/eth1/{*}
> 
>   2. meanwhile, on another terminal to observe the msg:
>   $ bridge monitor
> 
> [br_ioctl]
>   1. in bridge-utils package, do some changes in br_set, let brctl command
>   use ioctl to set attribute:
>          if ((ret = set_sysfs(path, value)) < 0) { -->
>          if (1) {
> 
>   $ brctl set*
> 
>   2. meanwhile, on another terminal to observe the msg:
>   $ bridge monitor
> 
> This test covers all the attributes that brctl and sysfs support to set.
> 

Overall the set looks good to me, just one comment for future posts - please
include the changes between versions of the set in your cover letter and 
individual patches. I had to go back to your previous postings and read my
own comments and compare them with this set.

Thank you,
 Nik
