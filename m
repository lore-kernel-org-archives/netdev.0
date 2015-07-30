From: Jason Wang <jasowang@redhat.com>
Subject: Re: [Question]Why a skb with frag_list causes BUG_ON in function
 skb_segment
Date: Thu, 30 Jul 2015 12:26:18 +0800
Message-ID: <55B9A76A.3030908@redhat.com>
References: <60A73B7A161A82449A7DB7B382BFD1553712AF1C@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Qinchuanyu <qinchuanyu@huawei.com>, Yewudi <yewudi@huawei.com>,
	liuyongan 00175866 <l00175866@notesmail.huawei.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60A73B7A161A82449A7DB7B382BFD1553712AF1C@SZXEMA504-MBS.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cc netdev for more experts

On 07/28/2015 04:53 PM, Zhangjie (HZ) wrote:
>
> Hi,
>
> I generate a skb as follows:
>
> It has a linear data region, 17 frags and the last fragment is in
> skb_shinfo(skb)->frag_list.
>
> Before this skb is sent to driver, dev_hard_start_xmit() will segment
> it first(skb has frag_list,
>
> so we get true from netif_needs_gso()), then the skb is passed to
> function skb_segment().
>
> Then, BUG_ON() happened.
>
> while (pos < offset + len) {
>
>         if (i >=3D nfrags) {
>
>                 BUG_ON(skb_headlen(list_skb));    (skbuff.c:3120)
>
>                 =E2=80=A6
>
>         }
>
>         =E2=80=A6
>
> }
>
> A skb that has no frags but frag_list also causes BUG_ON().
>
> I wonder if skb like follows is legal? Could skb in frag_list have
> linear data region?
>
> =20
>
> =20
>
> Thanks
>
> Zhangjie
>
