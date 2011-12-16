From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 0/2] vhot-net: Use kvm_memslots instead of vhost_memory
	to translate GPA to HVA
Date: Fri, 16 Dec 2011 09:59:18 +0200
Message-ID: <1324022358.4496.25.camel@lappy>
References: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
	<1324019151.4496.9.camel@lappy> <4EEAF5D1.2080805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: wusongwei@huawei.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, hanweidong@huawei.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	xiaowei.yang@huawei.com
To: Zang Hongyong <zanghongyong@huawei.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4EEAF5D1.2080805@huawei.com>
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

On Fri, 2011-12-16 at 15:40 +0800, Zang Hongyong wrote:
> 于 2011/12/16,星期五 15:05, Sasha Levin 写道:
> > On Fri, 2011-12-16 at 13:32 +0800, zanghongyong@huawei.com wrote:
> >> From: Hongyong Zang<zanghongyong@huawei.com>
> >>
> >> Vhost-net uses its own vhost_memory, which results from user space (qemu) info,
> >> to translate GPA to HVA. Since kernel's kvm structure already maintains the
> >> address relationship in its member *kvm_memslots*, these patches use kernel's
> >> kvm_memslots directly without the need of initialization and maintenance of
> >> vhost_memory.
> > Conceptually, vhost isn't aware of KVM - it's just a driver which moves
> > data from vq to a tap device and back. You can't simply add KVM specific
> > code into vhost.
> >
> > Whats the performance benefit?
> >
> But vhost-net is only used in virtualization situation. vhost_memory is 
> maintained
> by user space qemu.
> In this way, the memory relationship can be accquired from kernel 
> without the
> need of maintainence of vhost_memory from qemu.

You can't assume that vhost-* is used only along with qemu/kvm. Just as
virtio has more uses than just virtualization (heres one:
https://lkml.org/lkml/2011/10/25/139 ), there are more uses for vhost as
well.

There has been a great deal of effort to keep vhost and kvm untangled.
One example is the memory translation it has to do, another one is the
eventfd/irqfd thing it does just so it could signal an IRQ in the guest
instead of accessing the guest directly.

If you do see a great performance increase when tying vhost and KVM
together, it may be worth it to create some sort of an in-kernel
vhost-kvm bridging thing, but if the performance isn't noticeable we're
better off just leaving it as is and keeping the vhost code general.

-- 

Sasha.
