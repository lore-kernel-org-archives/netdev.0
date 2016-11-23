From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Wed, 23 Nov 2016 15:12:21 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201051D51@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>,<b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord [mlord@pobox.com]
[...]
> What does this code do:

> >static void r8153_set_rx_early_size(struct r8152 *tp)
> >{
> >        u32 mtu = tp->netdev->mtu;
> >        u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
> >
> >        ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
> >}

This only works for RTL8153. However, what you use is RTL8152.
It is like delay completion. It is used to reduce the loading of CPU
by letting a transfer contain more data to reduce the number of
transfers.

> How is ocp_data used by the hardware?
> Shouldn't the calculation also include sizeof(rx_desc) in there somewhere?

The algorithm is from our hw engineers, and it should be 

   (agg_buf_sz - packet size) / 8

You could refer to commit a59e6d815226 ("r8152: correct the rx early size").
