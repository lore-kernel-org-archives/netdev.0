From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Mon, 28 Nov 2011 12:25:15 +0800
Message-ID: <4ED30D2B.10907@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com>
	<20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com>
	<20111124161430.GC26770@redhat.com>
	<OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
	<4ECF09D5.4010700@redhat.com>
	<OF835A6FF5.7D752AD1-ON65257953.0016350C-65257953.00169AF4@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF835A6FF5.7D752AD1-ON65257953.0016350C-65257953.00169AF4@in.ibm.com>
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

On 11/25/2011 12:09 PM, Krishna Kumar2 wrote:
> Jason Wang<jasowang@redhat.com>  wrote on 11/25/2011 08:51:57 AM:
>> My description is not clear again :(
>> I mean the same vhost thead:
>>
>> vhost thread #0 transmits packets of flow A on processor M
>> ...
>> vhost thread #0 move to another process N and start to transmit packets
>> of flow A
> Thanks for clarifying. Yes, binding vhosts to CPU's
> makes the incoming packet go to the same vhost each
> time. BTW, are you doing any binding and/or irqbalance
> when you run your tests? I am not running either at
> this time, but thought both might be useful.

I'm using ixgbe for testing also, for host, its driver seems provide irq 
affinity hint, so no binding or irqbalance is needed. For guest, 
irqbalance is used in guest. I've tried bind irq in guest, and it can 
improve the rx performance.

> - KK
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
