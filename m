From: Jarno Rajahalme <jarno.rajahalme@gmail.com>
Subject: Re: Virtio_net support vxlan encapsulation package TSO offload discuss
Date: Thu, 17 Nov 2016 15:10:42 -0800
Message-ID: <3BA7D902-343E-4F3F-B78D-A31217D7C7CB@gmail.com>
References: <DBCD2614ECF3FF4087A2C27CA80E34DD5401AC8B@SZXEMA501-MBX.china.huawei.com> <c2f735e4-eddf-f737-2afe-35a93289f8d4@redhat.com> <3a0b8f10-f479-3ed5-dd10-5b92de3eb593@redhat.com> <DBCD2614ECF3FF4087A2C27CA80E34DD5401ADA8@SZXEMA501-MBX.china.huawei.com> <53d0322b-4ce1-d0db-4b53-f9e860ece2c5@redhat.com> <DBCD2614ECF3FF4087A2C27CA80E34DD5401BE13@SZXEMA501-MBX.china.huawei.com> <6db6b2a1-edbc-0068-d7d4-e8e15d18edc6@redhat.com> <DBCD2614ECF3FF4087A2C27CA80E34DD54027936@SZXEMA501-MBX.china.huawei.com> <0438366c-8b0e-270e-cbd1-334c1d655428@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "Zhangming (James, Euler)" <james.zhangming@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Vlad Yasevic <vyasevic@redhat.com>,
        Amnon Ilan <ailan@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35444 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752007AbcKQXKq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 18:10:46 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so18735107pga.2
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 15:10:46 -0800 (PST)
In-Reply-To: <0438366c-8b0e-270e-cbd1-334c1d655428@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I worked on the same issue a few months back. I rebased my =
proof-of-concept code to the current net-next and posted an RFC patch a =
moment ago.

I have zero experience on QEMU feature negotiation or extending the =
virtio_net spec. Since the virtio_net handling code is now all done =
using shared code, this should work for macvtap as well, not sure if =
macvtap needs some control plane changes.

I posted a separate patch to make af_packet also use the shared infra =
for virtio_net handling yesterday. My RFC patch assumes that af_packet =
need not be touched, i.e., assumes the af_packet patch is applied, even =
though the patches apply to net-next in either order.

  Jarno

> On Nov 16, 2016, at 11:27 PM, Jason Wang <jasowang@redhat.com> wrote:
>=20
>=20
>=20
> On 2016=E5=B9=B411=E6=9C=8817=E6=97=A5 09:31, Zhangming (James, Euler) =
wrote:
>> On 2016=E5=B9=B411=E6=9C=8815=E6=97=A5 11:28, Jason Wang wrote:
>>> On 2016=E5=B9=B411=E6=9C=8810=E6=97=A5 14:19, Zhangming (James, =
Euler) wrote:
>>>> On 2016=E5=B9=B411=E6=9C=8809=E6=97=A5 15:14, Jason Wang wrote:
>>>>> On 2016=E5=B9=B411=E6=9C=8808=E6=97=A5 19:58, Zhangming (James, =
Euler) wrote:
>>>>>> On 2016=E5=B9=B411=E6=9C=8808=E6=97=A5 19:17, Jason Wang wrote:
>>>>>>=20
>>>>>>> On 2016=E5=B9=B411=E6=9C=8808=E6=97=A5 19:13, Jason Wang wrote:
>>>>>>>> Cc Michael
>>>>>>>>=20
>>>>>>>> On 2016=E5=B9=B411=E6=9C=8808=E6=97=A5 16:34, Zhangming (James, =
Euler) wrote:
>>>>>>>>> In container scenario, OVS is installed in the Virtual =
machine,
>>>>>>>>> and all the containers connected to the OVS will communicated
>>>>>>>>> through VXLAN encapsulation.
>>>>>>>>>=20
>>>>>>>>> By now, virtio_net does not support TSO offload for VXLAN
>>>>>>>>> encapsulated TSO package. In this condition, the performance =
is
>>>>>>>>> not good, sender is bottleneck
>>>>>>>>>=20
>>>>>>>>> I googled this scenario, but I didn=E2=80=99t find any =
information. Will
>>>>>>>>> virtio_net support VXLAN encapsulation package TSO offload =
later?
>>>>>>>>>=20
>>>>>>>> Yes and for both sender and receiver.
>>>>>>>>=20
>>>>>>>>> My idea is virtio_net open encapsulated TSO offload, and
>>>>>>>>> transport encapsulation info to TUN, TUN will parse the info =
and
>>>>>>>>> build skb with encapsulation info.
>>>>>>>>>=20
>>>>>>>>> OVS or kernel on the host should be modified to support this.
>>>>>>>>> Using this method, the TCP performance aremore than 2x as =
before.
>>>>>>>>>=20
>>>>>>>>> Any advice and suggestions for this idea or new idea will be
>>>>>>>>> greatly appreciated!
>>>>>>>>>=20
>>>>>>>>> Best regards,
>>>>>>>>>=20
>>>>>>>>>      James zhang
>>>>>>>>>=20
>>>>>>>> Sounds very good. And we may also need features bits
>>>>>>>> (VIRTIO_NET_F_GUEST|HOST_GSO_X) for this.
>>>>>>>>=20
>>>>>>>> This is in fact one of items in networking todo list. (See
>>>>>>>> http://www.linux-kvm.org/page/NetworkingTodo). While at it, =
we'd
>>>>>>>> better support not only VXLAN but also other tunnels.
>>>>>>> Cc Vlad who is working on extending virtio-net headers.
>>>>>>>=20
>>>>>>>> We can start with the spec work, or if you've already had some
>>>>>>>> bits you can post them as RFC for early review.
>>>>>>>>=20
>>>>>>>> Thanks
>>>>>> Below is my demo code
>>>>>> Virtio_net.c
>>>>>> static int virtnet_probe(struct virtio_device *vdev), add belows =
codes:
>>>>>>           if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||	=
			// avoid gso segment, it should be negotiation =
later, because in the demo I reuse num_buffers.
>>>>>>               virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
>>>>>>                   dev->hw_enc_features |=3D NETIF_F_TSO;
>>>>>>                   dev->hw_enc_features |=3D NETIF_F_ALL_CSUM;
>>>>>>                   dev->hw_enc_features |=3D =
NETIF_F_GSO_UDP_TUNNEL;
>>>>>>                   dev->hw_enc_features |=3D =
NETIF_F_GSO_UDP_TUNNEL_CSUM;
>>>>>>                   dev->hw_enc_features |=3D
>>>>>> NETIF_F_GSO_TUNNEL_REMCSUM;
>>>>>>=20
>>>>>>                   dev->features |=3D NETIF_F_GSO_UDP_TUNNEL;
>>>>>>                   dev->features |=3D NETIF_F_GSO_UDP_TUNNEL_CSUM;
>>>>>>                   dev->features |=3D NETIF_F_GSO_TUNNEL_REMCSUM;
>>>>>>           }
>>>>>>=20
>>>>>> static int xmit_skb(struct send_queue *sq, struct sk_buff *skb), =
add
>>>>>> below to pieces of codes
>>>>>>=20
>>>>>>                   if (skb_shinfo(skb)->gso_type & =
SKB_GSO_UDP_TUNNEL)
>>>>>>                           hdr->hdr.gso_type |=3D =
VIRTIO_NET_HDR_GSO_TUNNEL;
>>>>>>                   if (skb_shinfo(skb)->gso_type & =
SKB_GSO_UDP_TUNNEL_CSUM)
>>>>>>                           hdr->hdr.gso_type |=3D =
VIRTIO_NET_HDR_GSO_TUNNEL_CSUM;
>>>>>>                   if (skb_shinfo(skb)->gso_type & =
SKB_GSO_TUNNEL_REMCSUM)
>>>>>>                           hdr->hdr.gso_type |=3D
>>>>>> VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM;
>>>>>>=20
>>>>>>           if (skb->encapsulation && skb_is_gso(skb)) {
>>>>>>                   inner_mac_len =3D skb_inner_network_header(skb) =
- skb_inner_mac_header(skb);
>>>>>>                   tnl_len =3D skb_inner_mac_header(skb) - =
skb_mac_header(skb);
>>>>>>                   if ( !(inner_mac_len >> DATA_LEN_SHIFT) && =
!(tnl_len >> DATA_LEN_SHIFT) ) {
>>>>>>                           hdr->hdr.flags |=3D =
VIRTIO_NET_HDR_F_ENCAPSULATION;
>>>>>>                           hdr->num_buffers =3D =
(__virtio16)((inner_mac_len << DATA_LEN_SHIFT) | tnl_len);		=
//we reuse num_buffers for simple , we should add extend member for =
later.
>>>>>>                   }  else
>>>>>>                           hdr->num_buffers =3D 0;
>>>>>>           }
>>>>>>=20
>>>>>> Tun.c
>>>>>>                   if (memcpy_fromiovecend((void *)&hdr, iv, =
offset, tun->vnet_hdr_sz))		//read header with negotiation =
length
>>>>>>                           return -EFAULT;
>>>>>>=20
>>>>>>                   if (hdr.gso_type & VIRTIO_NET_HDR_GSO_TUNNEL)		=
			//set tunnel gso info
>>>>>>                           skb_shinfo(skb)->gso_type |=3D =
SKB_GSO_UDP_TUNNEL;
>>>>>>                   if (hdr.gso_type & =
VIRTIO_NET_HDR_GSO_TUNNEL_CSUM)
>>>>>>                           skb_shinfo(skb)->gso_type |=3D =
SKB_GSO_UDP_TUNNEL_CSUM;
>>>>>>                   if (hdr.gso_type & =
VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM)
>>>>>>                           skb_shinfo(skb)->gso_type |=3D
>>>>>> SKB_GSO_TUNNEL_REMCSUM;
>>>>>>=20
>>>>>>           if (hdr.flags & VIRTIO_NET_HDR_F_ENCAPSULATION) {		=
				//read tunnel info from header and set =
to built skb.
>>>>>>                   tnl_len =3D tun16_to_cpu(tun, hdr.num_buffers) =
& TUN_TNL_LEN_MASK;
>>>>>>                   payload_mac_len =3D tun16_to_cpu(tun, =
hdr.num_buffers) >> TUN_DATA_LEN_SHIFT;
>>>>>>                   mac_len =3D skb_network_header(skb) - =
skb_mac_header(skb);
>>>>>>                   skb_set_inner_mac_header(skb, tnl_len - =
mac_len);
>>>>>>                   skb_set_inner_network_header(skb, tnl_len + =
payload_mac_len - mac_len);
>>>>>>                   skb->encapsulation =3D 1;
>>>>>>           }
>>>>>>=20
>>>>>>=20
>>>>> Something like this, and you probably need do something more:
>>>>>=20
>>>>> - use net-next.git to generate the patch (for the latest code)
>>>>> - add feature negotiation
>>>>> - tun/macvtap/qemu patches for this, you can start with =
tun/macvtap
>>>>> patches
>>>>> - support for all other SKB_GSO_* types which is not supported
>>>>> - use a new field instead of num_buffers
>>>>> - a virtio spec patch to describe the support for encapsulation
>>>>> offload
>>>>>=20
>>>>> Thanks
>>>> Thank you for your advice, I will start it right now.
>>>>=20
>>>> Thanks
>>> Cool, one more question: while at it, I think you may want to add =
support for dpdk too?
>>>=20
>>> Thanks
>> Do you mean that the patch should be compatible with virtio pmd, or =
give virtio pmd patch?
>>=20
>> Thanks
>=20
> I mean it's better to prepare patches for both virtio pmd and dpdk.
>=20
> Thanks
