From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 2/5] tuntap: simple flow director support
Date: Tue, 06 Dec 2011 15:21:33 +0800
Message-ID: <4EDDC27D.9050608@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
	<1323115763.2887.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1323115763.2887.12.camel@bwh-desktop>
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

On 12/06/2011 04:09 AM, Ben Hutchings wrote:
> On Mon, 2011-12-05 at 16:58 +0800, Jason Wang wrote:
>> This patch adds a simple flow director to tun/tap device. It is just a
>> page that contains the hash to queue mapping which could be changed by
>> user-space. The backend (tap/macvtap) would query this table to get
>> the desired queue of a packets when it send packets to userspace.
> This is just flow hashing (RSS), not flow steering.
>
>> The page address were set through a new kind of ioctl - TUNSETFD and
>> were pinned until device exit or another new page were specified.
> [...]
>
> You should implement ethtool ETHTOOL_{G,S}RXFHINDIR instead.
>
> Ben.
>

I'm not fully understanding this. The page belongs to guest, and the 
idea is to let guest driver can easily change any entry. Looks like if 
ethtool_set_rxfh_indir() is used, this kind of change is not easy as it 
needs one copy and can only accept the whole table as its parameters.
