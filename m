From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Tue, 16 Dec 2008 10:13:30 +0100
Message-ID: <200812161013.31339.manfred.scherer.mhm@t-online.de>
References: <1229384410-16879-1-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mostrows@gmail.com,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.t-online.de ([194.25.134.80]:37847 "EHLO
	mailout01.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbYLPQU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 11:20:58 -0500
In-Reply-To: <1229384410-16879-1-git-send-email-sakari.ailus@iki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tested this patch with success.

here are my test scenarios:

load the pached module:

pc1:/lib/modules/2.6.27/kernel/drivers/net # rmmod tlan
pc1:/lib/modules/2.6.27/kernel/drivers/net # cp -p tlan.ko.2.6.27_sakari.ailus tlan.ko
pc1:/lib/modules/2.6.27/kernel/drivers/net # modprobe tlan

browser access to the DSL-modem:

pc1:/lib/modules/2.6.27/kernel/drivers/net # tcpdump -i eth1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
09:37:50.167945 arp who-has 192.168.1.1 tell 192.168.1.22
09:37:50.168179 arp reply 192.168.1.1 is-at 00:19:15:47:0e:11
09:37:50.168197 IP 192.168.1.22.avsecuremgmt > 192.168.1.1.http: S 3925686798:3925686798(0) win 5840 <sackOK,timestamp 91699898 0,mss 1460,nop,wscale 6>
09:37:50.168693 arp who-has 192.168.1.22 tell 192.168.1.1
09:37:50.168719 arp reply 192.168.1.22 is-at 00:08:c7:28:5a:96
09:37:50.169204 IP 192.168.1.1.http > 192.168.1.22.avsecuremgmt: S 0:0(0) ack 3925686799 win 49152 <mss 1400>
09:37:50.169344 IP 192.168.1.22.avsecuremgmt > 192.168.1.1.http: . ack 1 win 5840
09:37:50.169475 IP 192.168.1.22.avsecuremgmt > 192.168.1.1.http: P 1:364(363) ack 1 win 5840
09:37:50.169716 IP 192.168.1.1.http > 192.168.1.22.avsecuremgmt: . ack 1 win 49152
09:37:50.170227 IP 192.168.1.1.http > 192.168.1.22.avsecuremgmt: . 1:28(27) ack 364 win 49152
09:37:50.170292 IP 192.168.1.22.avsecuremgmt > 192.168.1.1.http: . ack 28 win 5840
09:37:50.170738 IP 192.168.1.1.http > 192.168.1.22.avsecuremgmt: . 28:398(370) ack 364 win 49152
09:37:50.170796 IP 192.168.1.22.avsecuremgmt > 192.168.1.1.http: . ack 398 win 6432
...


Access to the internet via ppoe does work also:

Dec 16 09:34:46 pc1 kernel: ThunderLAN driver v1.15
Dec 16 09:34:46 pc1 kernel: TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI UTP, Rev. 16
Dec 16 09:34:46 pc1 kernel: TLAN: 1 device installed, PCI: 1  EISA: 0
Dec 16 09:34:57 pc1 kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Dec 16 09:34:57 pc1 kernel: TLAN: eth1: Starting autonegotiation.
Dec 16 09:34:59 pc1 kernel: TLAN: eth1: Autonegotiation complete.
Dec 16 09:34:59 pc1 kernel: TLAN: eth1: Link active with AutoNegotiation enabled, at 100Mbps Full-Duplex
Dec 16 09:34:59 pc1 kernel: TLAN: Partner capability: 10BaseT-HD 10BaseT-FD 100baseTx-HD 100baseTx-FD<NULL>
Dec 16 09:34:59 pc1 kernel: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Dec 16 09:35:10 pc1 kernel: eth1: no IPv6 routers present
Dec 16 09:35:22 pc1 kernel: device eth1 entered promiscuous mode
Dec 16 09:41:26 pc1 kernel: device eth1 left promiscuous mode
Dec 16 09:41:46 pc1 pppd[14895]: Plugin rp-pppoe.so loaded.
Dec 16 09:41:46 pc1 pppd[14895]: RP-PPPoE plugin version 3.3 compiled against pppd 2.4.2
Dec 16 09:41:46 pc1 pppd[14895]: Plugin passwordfd.so loaded.
Dec 16 09:41:46 pc1 pppd[14895]: pppd 2.4.2 started by root, uid 0
Dec 16 09:41:47 pc1 pppd[14895]: PPP session is 1299
Dec 16 09:41:47 pc1 pppd[14895]: Renamed interface ppp0 to dsl0
Dec 16 09:41:47 pc1 pppd[14895]: Using interface dsl0
Dec 16 09:41:47 pc1 pppd[14895]: Connect: dsl0 <--> eth1
Dec 16 09:41:47 pc1 pppd[14895]: Couldn't increase MTU to 1500
Dec 16 09:41:47 pc1 pppd[14895]: Couldn't increase MRU to 1500
Dec 16 09:41:47 pc1 pppd[14895]: PAP authentication succeeded
Dec 16 09:41:47 pc1 pppd[14895]: peer from calling number 00:90:1A:A0:BF:67 authorized
Dec 16 09:41:47 pc1 pppd[14895]: local  IP address 87.178.120.71
Dec 16 09:41:47 pc1 pppd[14895]: remote IP address 217.0.117.13
Dec 16 09:41:47 pc1 pppd[14895]: primary   DNS address 217.237.150.51
Dec 16 09:41:47 pc1 pppd[14895]: secondary DNS address 217.237.148.22
Dec 16 09:41:47 pc1 modify_resolvconf: Service pppd modified /etc/resolv.conf. See info block in this file
Dec 16 09:41:54 pc1 pppd[14895]: Script /etc/ppp/ip-up finished (pid 14919), status = 0x0

... an now I am online and send this email.

Manfred Scherer
____________________________________________________________________________

Am Dienstag, 16. Dezember 2008 00:40 schrieben Sie:
> The TLAN chip does not support tranmissions smaller than 64 bytes. Smaller
> transfers need to be padded up to that size. This was broken by commit id
> 41873e9aff0632d80c74380d58a89e8d420151bd.
> 
> <URL:http://bugzilla.kernel.org/show_bug.cgi?id=11754>
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
> ---
>  drivers/net/tlan.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
> index c41d687..cf8cdaf 100644
> --- a/drivers/net/tlan.c
> +++ b/drivers/net/tlan.c
> @@ -1098,6 +1098,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
>  	dma_addr_t	tail_list_phys;
>  	u8		*tail_buffer;
>  	unsigned long	flags;
> +	unsigned int    txlen;
>  
>  	if ( ! priv->phyOnline ) {
>  		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
> @@ -1108,6 +1109,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
>  
>  	if (skb_padto(skb, TLAN_MIN_FRAME_SIZE))
>  		return 0;
> +	txlen = max(skb->len, (unsigned int)TLAN_MIN_FRAME_SIZE);
>  
>  	tail_list = priv->txList + priv->txTail;
>  	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
> @@ -1125,16 +1127,16 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
>  
>  	if ( bbuf ) {
>  		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
> -		skb_copy_from_linear_data(skb, tail_buffer, skb->len);
> +		skb_copy_from_linear_data(skb, tail_buffer, txlen);
>  	} else {
>  		tail_list->buffer[0].address = pci_map_single(priv->pciDev,
> -							      skb->data, skb->len,
> +							      skb->data, txlen,
>  							      PCI_DMA_TODEVICE);
>  		TLan_StoreSKB(tail_list, skb);
>  	}
>  
> -	tail_list->frameSize = (u16) skb->len;
> -	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
> +	tail_list->frameSize = (u16) txlen;
> +	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) txlen;
>  	tail_list->buffer[1].count = 0;
>  	tail_list->buffer[1].address = 0;
>  
