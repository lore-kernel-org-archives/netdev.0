From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 08:56:34 -0800
Message-ID: <52E7E142.8000407@hp.com>
References: <52E766D4.4070901@huawei.com> <20140128083459.GB16833@redhat.com> <52E77506.1080604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <52E77506.1080604@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2014 01:14 AM, Qin Chuanyu wrote:
> On 2014/1/28 16:34, Michael S. Tsirkin wrote:
>> Could you please check latency results?
>>
> netperf UDP_RR 512
> test model: VM->host->host
>
> modified before : 11108
> modified after  : 11480
>
> 3% gained by this patch

Netperf UDP_RR can be very sensitive to packet losses.  Not that there 
were necessarily any in your tests, but to further confirm the 3% 
improvement in latency, I would suggest using the confidence intervals 
functionality in your before/after netperf testing.  And to get at what 
Michael asks about CPU utilization I would suggest:

netperf -H <otherguy> -c -C -l 30 -i 30,3 -t UDP_RR -- -r 512

(I was guessing as to what netperf options you may have been using already)

happy benchmarking,

rick jones

