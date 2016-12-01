From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 0/6] XDP for virtio_net
Date: Wed, 30 Nov 2016 20:26:17 -0800
Message-ID: <583FA669.4020408@gmail.com>
References: <20161129200450.26752.86882.stgit@john-Precision-Tower-5810>
 <20161130203450-mutt-send-email-mst@kernel.org> <583F1D40.7060408@gmail.com>
 <20161130205527-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35279 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753591AbcLAE0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 23:26:35 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so3314389pga.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 20:26:34 -0800 (PST)
In-Reply-To: <20161130205527-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-30 10:56 AM, Michael S. Tsirkin wrote:
> On Wed, Nov 30, 2016 at 10:41:04AM -0800, John Fastabend wrote:
>> On 16-11-30 10:35 AM, Michael S. Tsirkin wrote:
>>> On Tue, Nov 29, 2016 at 12:05:20PM -0800, John Fastabend wrote:
>>>> This implements virtio_net for the mergeable buffers and big_packet
>>>> modes. I tested this with vhost_net running on qemu and did not see
>>>> any issues. For testing num_buf > 1 I added a hack to vhost driver
>>>> to only but 100 bytes per buffer.
>>>>
>>>> There are some restrictions for XDP to be enabled and work well
>>>> (see patch 3) for more details.
>>>>
>>>>   1. LRO must be off
>>>>   2. MTU must be less than PAGE_SIZE
>>>>   3. queues must be available to dedicate to XDP
>>>>   4. num_bufs received in mergeable buffers must be 1
>>>>   5. big_packet mode must have all data on single page
>>>>
>>>> Please review any comments/feedback welcome as always.
>>>>
>>>> v2, fixes rcu usage throughout thanks to Eric and the use of
>>>> num_online_cpus() usage thanks to Jakub.
>>>>
>>>> v3, add slowpath patch to handle num_bufs > 1
>>>>
>>>> Thanks,
>>>> John
>>>
>>> BTW this is threaded incorrectly: patch 1/6 isn't a reply to 0/6,
>>> patches 2 and on are replies to patch 1.
>>>
>>
>> Ah yep, if you mangle the command line git will send the
>> cover letter even if you have mangled 'to' email addresses but when
>> it hits a real patch it aborts. At least on my version of git.
>>
>>> I'm busy until end of week, I'll review Monday. Sorry about the delay.
>>
>> In the meantime I'll post a v4 with better commit message (Alexei) and
>> address a corner cases Jakub pointed out.
> 
> I did a quick look and found some too, but a detailed review will
> have to wait till next week.

Thanks! I'll address all the comments and have a v4 by then.
