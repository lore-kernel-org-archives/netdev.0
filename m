From: Robert Vineyard <vineyard@tuffmail.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Sat, 11 Aug 2012 20:42:44 -0400
Message-ID: <5026FC04.6080108@tuffmail.com>
References: <50248148.4070204@huawei.com>
	<20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
	<5026D49B.10305@tuffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, "Peter Huang\(Peng\)" <peter.huangpeng@huawei.com>,
	virtualization@lists.linux-foundation.org, avi@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5026D49B.10305@tuffmail.com>
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

(adding Xin Xiaohui to the conversation for comment)

According to the NetworkingTodo page on the KVM wiki, zero-copy RX for 
macvtap is in fact on the roadmap, assigned to Xin:

http://www.linux-kvm.org/page/NetworkingTodo

The Release Notes for RHEL 6.2 (originally published on 12/06/2011) also 
specifically mention macvtap/vhost zero-copy capabilities as being 
included as a Technology Preview:

http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/6.2_Release_Notes/virtualization.html

Since I've been unable to find much information on the current status of 
this development, can anyone confirm if this functionality is still in 
the works? If so, is there any planned ETA?

Thanks,
Robert Vineyard


On 08/11/2012 05:54 PM, Robert Vineyard wrote:
>> On Fri, 10 Aug 2012 11:34:32 +0800
>> "Peter Huang(Peng)" <peter.huangpeng@huawei.com> wrote:
>>
>>> I searched from git-log, and found that until now we have vhost TX
>>> zero-copy experiment feature, how
>>> about RX zero-copy?
>
> On 08/11/2012 04:55 PM, Stephen Hemminger wrote:
>> There is no guarantee that packet will ever be read by receiver. This
>> means zero-copy could
>> create memory back pressure stalls.
>
> It would be handy if this could be an optional feature, perhaps not
> enabled by default due to the problem with stalls you mentioned. I would
> love to see RX zero-copy implemented natively in KVM, as it might
> alleviate the need for custom solutions like vPF_RING:
>
> http://www.ntop.org/products/pf_ring/vpf_ring/
>
> Every time a packet is copied, especially from kernel space to user
> space, there is an opportunity for it to be dropped on its way to the
> receiving application - which is unacceptable when monitoring high-speed
> networks for security or bandwidth accounting purposes.
>
> I am attempting to find a highly-efficient way to deploy virtualized
> network monitoring sensors (Snort, for example). Ideally I want to
> exploit symmetric hardware-based RSS and SR-IOV functionality for
> load-balancing and packet distribution completely in ASIC. I've found
> other existing work in this area (also using custom drivers) indicating
> significant performance gains in the non-virtualized case:
>
> http://www.ndsl.kaist.edu/~shinae/papers/TR-symRSS.pdf
>
> Is there any interest in exploring native RX zero-copy within the
> mainline KVM networking code?
>
> Thanks,
> Robert Vineyard
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
