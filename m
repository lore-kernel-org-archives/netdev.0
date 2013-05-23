From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: provide vhost thread per virtqueue for forwarding scenario
Date: Thu, 23 May 2013 13:43:29 +0930
Message-ID: <8738tes592.fsf@rustcorp.com.au>
References: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com> <20130520074300.GA27848@redhat.com> <519C96E7.2030704@huawei.com> <519C98E2.9000102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qinchuanyu <qinchuanyu@huawei.com>,
	"nab\@linux-iscsi.org" <nab@linux-iscsi.org>,
	"\(netdev\@vger.kernel.org\)" <netdev@vger.kernel.org>,
	"\(kvm\@vger.kernel.org\)" <kvm@vger.kernel.org>,
	"Zhangjie \(HZ\)" <zhang.zhangjie@huawei.com>
To: Jason Wang <jasowang@redhat.com>,
	Zang Hongyong <zanghongyong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45722 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab3EWE4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 00:56:50 -0400
In-Reply-To: <519C98E2.9000102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Wang <jasowang@redhat.com> writes:
> On 05/22/2013 05:59 PM, Zang Hongyong wrote:
>> On 2013/5/20 15:43, Michael S. Tsirkin wrote:
>>> On Mon, May 20, 2013 at 02:11:19AM +0000, Qinchuanyu wrote:
>>> Yes, I don't think we want to create threads even more aggressively
>>> in all cases. I'm worried about scalability as it is.
>>> I think we should explore a flexible approach, use a thread pool
>>> (for example, a wq) to share threads between virtqueues,
>>> switch to a separate thread only if there's free CPU and existing
>>> threads are busy. Hopefully share threads between vhost instances too.
>> On Xen platform, network backend pv driver model has evolved to this
>> way. Netbacks from all DomUs share a thread pool,
>> and thread number eaqual to cpu core number.
>> Is there any plan for kvm paltform?
>
> There used to be two related RFCs for this, one is the multiple vhost
> workers from Anthony another is percpu vhost thread from Shirley. You
> can search the archives on netdev or kvm for the patches.

As I've said to MST before, I think our entire model is wrong.
Userspace should create the threads and call in.  If you're doing kernel
acceleration, two extra threads per NIC is a tiny overhead.

Of course, such radical changes to vhost doesn't help existing users as
Qinchuanyu asked...

Cheers,
Rusty,
