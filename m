From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Fri, 25 Nov 2011 11:21:57 +0800
Message-ID: <4ECF09D5.4010700@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com>
	<20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com>
	<20111124161430.GC26770@redhat.com>
	<OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
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

On 11/25/2011 11:07 AM, Krishna Kumar2 wrote:
> "Michael S. Tsirkin"<mst@redhat.com>  wrote on 11/24/2011 09:44:31 PM:
>
>>> As far as I can see, ixgbe binds queues to physical cpu, so let
> consider:
>>> vhost thread transmits packets of flow A on processor M
>>> during packet transmission, ixgbe driver programs the card to
>>> deliver the packet of flow A to queue/cpu M through flow director
>>> (see ixgbe_atr())
>>> vhost thread then receives packet of flow A with from M
>>> ...
>>> vhost thread transmits packets of flow A on processor N
>>> ixgbe driver programs the flow director to change the delivery of
>>> flow A to queue N ( cpu N )
>>> vhost thread then receives packet of flow A with from N
>>> ...
>>>
>>> So, for a single flow A, we may get different queue mappings. Using
>>> rxhash instead may solve this issue.
>> Or better, transmit a single flow from a single vhost thread.
>>
>> If packets of a single flow get spread over different CPUs,
>> they will get reordered and things are not going to work well.
> My testing so far shows that guest sends on (e.g.) TXQ#2
> only, which is handled by vhost#2; and this doesn't change
> for the entire duration of the test. Incoming keeps
> changing for different packets but become same with
> this patch. To iterate, I have not seen the following:

Yes because guest chose the txq of virtio-net based on hash.

>
> "
> vhost thread transmits packets of flow A on processor M
> ...
> vhost thread transmits packets of flow A on processor N
> "

My description is not clear again :(
I mean the same vhost thead:

vhost thread #0 transmits packets of flow A on processor M
...
vhost thread #0 move to another process N and start to transmit packets 
of flow A

> - KK
>
