From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: =?UTF-8?B?UmU6IElzIGZhbGxiYWNrIHZob3N0X25ldCB0byBxZW11IGZvciBsaXY=?=
 =?UTF-8?B?ZSBtaWdyYXRlIGF2YWlsYWJsZe+8nw==?=
Date: Tue, 3 Sep 2013 09:28:11 +0800
Message-ID: <52253B2B.6050909@huawei.com>
References: <521C1DCF.5090202@huawei.com> <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com> <522174D7.6080903@huawei.com> <20130902075722.GZ15729@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<wangfuhai@huawei.com>, <likunyun@huawei.com>,
	<liuyongan@huawei.com>, <liuyingdong@huawei.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:8417 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522Ab3ICB2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 21:28:55 -0400
In-Reply-To: <20130902075722.GZ15729@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/9/2 15:57, Wei Liu wrote:
> On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
>> On 2013/8/30 0:08, Anthony Liguori wrote:
>>> Hi Qin,
>>
>>>> By change the memory copy and notify mechanism =EF=BC=8Ccurrently =
virtio-net with
>>>> vhost_net could run on Xen with good performance=E3=80=82
>>>
>>> I think the key in doing this would be to implement a property
>>> ioeventfd and irqfd interface in the driver domain kernel.  Just
>>> hacking vhost_net with Xen specific knowledge would be pretty nasty
>>> IMHO.
>>>
>> Yes, I add a kernel module which persist virtio-net pio_addr and
>> msix address as what kvm module did. Guest wake up vhost thread by
>> adding a hook func in evtchn_interrupt.
>>
>>> Did you modify the front end driver to do grant table mapping or is
>>> this all being done by mapping the domain's memory?
>>>
>> There is nothing changed in front end driver. Currently I use
>> alloc_vm_area to get address space=EF=BC=8C and map the domain's mem=
ory as
>> what what qemu did.
>>
>
> You mean you're using xc_map_foreign_range and friends in the backend=
 to
> map guest memory? That's not very desirable as it violates Xen's
> security model. It would not be too hard to pass grant references
> instead of guest physical memory address IMHO.
>
In fact, I did what virtio-net have done in Qemu. I think security
is a pseudo question because Dom0 is under control.

Host could access memory of guest in KVM much easier than Xen,
but I hadn't heard someone said KVM is un-secret.

Regards
Qin chuanyu
