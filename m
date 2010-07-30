From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
Date: Fri, 30 Jul 2010 08:02:10 +0300
Message-ID: <4C525CD2.5080604@redhat.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com> <1280442682.9058.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280442682.9058.15.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  On 07/30/2010 01:31 AM, Shirley Ma wrote:
>
>> Our goal is to improve the bandwidth and reduce the CPU usage.
>> Exact performance data will be provided later.
> I did some vhost performance measurement over 10Gb ixgbe, and found that
> in order to get consistent BW results, netperf/netserver, qemu, vhost
> threads smp affinities are required.
>
> Looking forward to these results for small message size comparison. For
> large message size 10Gb ixgbe BW already reached by doing vhost smp
> affinity w/i offloading support, we will see how much CPU utilization it
> can be reduced.
>
> Please provide latency results as well. I did some experimental on
> macvtap zero copy sendmsg, what I have found that get_user_pages latency
> pretty high.
>

get_user_pages() is indeed slow.  But what about get_user_pages_fast()?

Note that when the page is first touched, get_user_pages_fast() falls 
back to get_user_pages(), so the latency needs to be measured after 
quite a bit of warm-up.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
