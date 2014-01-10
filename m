From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Fri, 10 Jan 2014 15:06:52 +0800
Message-ID: <52CF9C0C.2020808@redhat.com>
References: <52CA5CDA.1020503@gmail.com>	<52CA612D.2000902@redhat.com>	<20140106122628.GA24280@hmsreliant.think-freely.org>	<52CB7009.2030903@redhat.com>	<52CB8D54.9090506@gmail.com>	<52CB9D1A.1050101@redhat.com>	<52CBAC2A.90005@intel.com>	<52CBC22D.3050002@redhat.com>	<20140108125528.GC14741@redhat.com>	<52CDA186.1080601@gmail.com>	<20140109071721.GD19559@redhat.com>	<52CE63EB.5000109@redhat.com> <20140109133908.354a4d73@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109133908.354a4d73@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2014 05:39 AM, Stephen Hemminger wrote:
> On Thu, 09 Jan 2014 16:55:07 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> What if use do want a qdisc and want to change the its queue length for
>> tun/macvlan? And the the name tx_queue_length is misleading. For tun it
>> may make sense since it was used in transmission path. For macvtap it
>> was not. So maybe what we need is just a new ioctl for both tun/macvtap
>> and a new feature flag. If user create the device with new feature flag,
>> the socket receive queue length could be changed by ioctl instead of
>> dev->tx_queue_length. If not, the old behaviour could be kept.
> The overloading of tx_queue_len in macvtap was the original design mistake.
> Can't this just be undone and expose rx_queue_len as sysfs attribute?

That works. But we current allow user to change the socket sndbuf
through TUNSNDBUF. Maybe we need a similar one for receive.
