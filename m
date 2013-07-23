From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tuntap: hardware vlan tx support
Date: Tue, 23 Jul 2013 08:17:27 -0700
Message-ID: <20130723081727.69766d27@nehalam.linuxnetplumber.net>
References: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jul 2013 15:15:48 +0800
Jason Wang <jasowang@redhat.com> wrote:

> Inspired by commit f09e2249c4f5c7c13261ec73f5a7807076af0c8e (macvtap: restore
> vlan header on user read). This patch adds hardware vlan tx support for
> tuntap. This is done by copying vlan header directly into userspace in
> tun_put_user() instead of doing it through __vlan_put_tag() in
> dev_hard_start_xmit(). This eliminates one unnecessary memove in
> vlan_insert_tag() for 802.1ad and 802.1q traffic.
> 
> pktgen test shows about 20% improvement for 802.1q traffic:
> 
> Before:
>   662149pps 317Mb/sec (317831520bps) errors: 0
> After:
>   801033pps 384Mb/sec (384495840bps) errors: 0
> 
> Cc: Basil Gor <basil.gor@gmail.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>


You need to make this configurable by some mechanism, since otherwise
it will break applications that expect current VLAN behavior
