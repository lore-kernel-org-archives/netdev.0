From: Robert Vineyard <vineyard@tuffmail.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Sat, 11 Aug 2012 17:54:35 -0400
Message-ID: <5026D49B.10305@tuffmail.com>
References: <50248148.4070204@huawei.com> <20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 10 Aug 2012 11:34:32 +0800
> "Peter Huang(Peng)" <peter.huangpeng@huawei.com> wrote:
>
>> I searched from git-log, and found that until now we have vhost TX zero-copy experiment feature, how
>> about RX zero-copy?

On 08/11/2012 04:55 PM, Stephen Hemminger wrote:
> There is no guarantee that packet will ever be read by receiver. This means zero-copy could
> create memory back pressure stalls.

It would be handy if this could be an optional feature, perhaps not 
enabled by default due to the problem with stalls you mentioned. I would 
love to see RX zero-copy implemented natively in KVM, as it might 
alleviate the need for custom solutions like vPF_RING:

http://www.ntop.org/products/pf_ring/vpf_ring/

Every time a packet is copied, especially from kernel space to user 
space, there is an opportunity for it to be dropped on its way to the 
receiving application - which is unacceptable when monitoring high-speed 
networks for security or bandwidth accounting purposes.

I am attempting to find a highly-efficient way to deploy virtualized 
network monitoring sensors (Snort, for example). Ideally I want to 
exploit symmetric hardware-based RSS and SR-IOV functionality for 
load-balancing and packet distribution completely in ASIC. I've found 
other existing work in this area (also using custom drivers) indicating 
significant performance gains in the non-virtualized case:

http://www.ndsl.kaist.edu/~shinae/papers/TR-symRSS.pdf

Is there any interest in exploring native RX zero-copy within the 
mainline KVM networking code?

Thanks,
Robert Vineyard
