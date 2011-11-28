From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Mon, 28 Nov 2011 12:40:47 +0800
Message-ID: <4ED310CF.6010306@redhat.com>
References: <OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
	<4ECF09D5.4010700@redhat.com>
	<OF835A6FF5.7D752AD1-ON65257953.0016350C-65257953.00169AF4@in.ibm.com>
	<20111125.013552.1613051198566054931.davem@davemloft.net>
	<20111127172333.GD31987@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, arnd@arndb.de, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111127172333.GD31987@redhat.com>
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

On 11/28/2011 01:23 AM, Michael S. Tsirkin wrote:
> On Fri, Nov 25, 2011 at 01:35:52AM -0500, David Miller wrote:
>> From: Krishna Kumar2<krkumar2@in.ibm.com>
>> Date: Fri, 25 Nov 2011 09:39:11 +0530
>>
>>> Jason Wang<jasowang@redhat.com>  wrote on 11/25/2011 08:51:57 AM:
>>>> My description is not clear again :(
>>>> I mean the same vhost thead:
>>>>
>>>> vhost thread #0 transmits packets of flow A on processor M
>>>> ...
>>>> vhost thread #0 move to another process N and start to transmit packets
>>>> of flow A
>>> Thanks for clarifying. Yes, binding vhosts to CPU's
>>> makes the incoming packet go to the same vhost each
>>> time. BTW, are you doing any binding and/or irqbalance
>>> when you run your tests? I am not running either at
>>> this time, but thought both might be useful.
>> So are we going with this patch or are we saying that vhost binding
>> is a requirement?
> I think it's a good idea to make sure we understand the problem
> root cause well before applying the patch. We still
> have a bit of time before 3.2. In particular, why does
> the vhost thread bounce between CPUs so much?

Other than this, since we could not assume the behavior of the under 
nic, using rxhash to identify a flow is more generic way.
>
> Long term it seems the best way is to expose the preferred mapping
> from the guest and forward it to the device.
>

I was working on this and hope to post it soon.
