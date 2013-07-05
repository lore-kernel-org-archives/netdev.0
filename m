From: Jason Wang <jasowang@redhat.com>
Subject: Re: tuntap regression in v3.9.8 and v3.10
Date: Fri, 05 Jul 2013 11:43:30 +0800
Message-ID: <51D640E2.1010809@redhat.com>
References: <20130702195910.GA20271@toau.bambla> <CAOMZO5B7Yx7tRy8Q5wi6ngcD0FDJzKXHOEGPXyUo52+f3oUHEg@mail.gmail.com> <20130702220651.GA23097@toau.bambla> <51D39010.5090902@redhat.com> <20130703061104.GA22847@toau.bambla>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081Ab3GEDnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jul 2013 23:43:49 -0400
In-Reply-To: <20130703061104.GA22847@toau.bambla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2013 02:11 PM, Thomas Zeitlhofer wrote:
> Hello Jason,
>
> On Wed, Jul 03, 2013 at 10:44:32AM +0800, Jason Wang wrote:
>> On 07/03/2013 06:06 AM, Thomas Zeitlhofer wrote:
>>> On Tue, Jul 02, 2013 at 06:01:12PM -0300, Fabio Estevam wrote:
>>>> On Tue, Jul 2, 2013 at 4:59 PM, Thomas Zeitlhofer
>>>> <thomas.zeitlhofer@nt.tuwien.ac.at> wrote:
>>>>> Commit "tuntap: set SOCK_ZEROCOPY flag during open" introduces a
>>>>> regression which is observed with live migration of qemu/kvm based
>>>>> virtual machines that are connected to an openvswitch bridge.
>>>>>
>>>>> Reverting this commit (b26c93c46a3dec25ed236d4ba6107eb4ed5d9401 in
>>>>> v3.9.8 and accordingly 19a6afb23e5d323e1245baa4e62755492b2f1200 in
>>>>> v3.10) fixes the following problem:
>>>> Should the sock_set_flag stay in tun_set_iff as it was prior to 54f968d6efd?
>>>>
>>>> --- a/drivers/net/tun.c
>>>> +++ b/drivers/net/tun.c
>>>> @@ -1652,6 +1652,7 @@ static int tun_set_iff(struct net *net, struct
>>>> file *file, struct ifreq *ifr)
>>>>                 tun->txflt.count = 0;
>>>>                 tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
>>>>
>>>> +               sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
>>>>                 tun->filter_attached = false;
>>>>                 tun->sndbuf = tfile->socket.sk->sk_sndbuf;
>>>>
>>>> @@ -2159,8 +2160,6 @@ static int tun_chr_open(struct inode *inode,
>>>> struct file * file)
>>>>         set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
>>>>         INIT_LIST_HEAD(&tfile->next);
>>>>
>>>> -       sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
>>>> -
>>>>         return 0;
>>>>  }
>>> I guess no, as this also leads to a kernel panic (tested against v3.10).
>> Yes, commit "tuntap: set SOCK_ZEROCOPY flag during open" just re-enable
>> the zerocopy capability of tuntap. I believe it just uncover other
>> zerocopy bugs.
>>
>> Which regression did you see?
> a kernel panic on the host machine. The details are in the first message
> of this thread: http://lkml.org/lkml/2013/7/2/499

Could you please have a try with the patch in
https://lkml.org/lkml/2013/6/25/304.

Michael, please resubmit a patch which can applies cleanly.

Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
