From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during network stress and
 OOM
Date: Mon, 30 Jan 2017 09:13:57 -0800
Message-ID: <d7f6178f-9d11-daaf-b73a-d572862fe7ea@amazon.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
 <38ccfaea-0a65-a6f3-c19a-e6f9c0d4ef76@oracle.com>
 <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
 <30069778-9509-8112-5089-2eea7b679236@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
        <netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        xen-devel <xen-devel@lists.xen.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30069778-9509-8112-5089-2eea7b679236@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 01/30/2017 09:06 AM, Boris Ostrovsky wrote:
> On 01/30/2017 11:47 AM, Vineeth Remanan Pillai wrote:
>
>>> 2. It tickles a latent bug during resume where the timer triggers
>>> before we re-connect. The trouble is that we now try to dereference
>>> queue->rx.sring which is NULL since we disconnect in
>>> netfront_resume(). (Curiously, I only observe it with 32-bit guests)
>> I think we may hit this bug after removing the timer as well. We call
>> RING_PUSH_REQUESTS_AND_CHECK_NOTIFY soon after, which also dereference
>> queue->rx.sring.
> If the timer is deleted in xennet_disconnect_backend() then why would
> anyone be pushing anything to the backend after that?
Sorry, I got the ordering wrong. Thanks for the clarification..

Thanks,
Vineeth
