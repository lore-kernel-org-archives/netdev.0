From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 10:17:59 -0700
Message-ID: <599C6747.8010005@gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <20170821223540.atktdricmks26c27@ast-mbp> <20170822083710.47a182a2@redhat.com> <20170822170913.35umf4j6hlmcnwtm@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37659 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdHVRSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:18:12 -0400
In-Reply-To: <20170822170913.35umf4j6hlmcnwtm@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:09 AM, Alexei Starovoitov wrote:
> On Tue, Aug 22, 2017 at 08:37:10AM +0200, Jesper Dangaard Brouer wrote:
>>
>>
>>> Once tx-ing netdev added to devmap we can enable xdp on it automatically?
>>
>> I think you are referring to Gotcha-2 here:
> 
> oops. yes :)
> 
>>
>>   Second gotcha(2): you cannot TX out a device, unless it also have a
>>   xdp bpf program attached. (This is an implicit dependency, as the
>>   driver code need to setup XDP resources before it can ndo_xdp_xmit).
>>
>> Yes, we should work on improving this situation.  Auto enabling XDP
>> when a netdev is added to a devmap is a good solution.  Currently this
>> is tied to loading an XDP bpf_prog.  Do you propose loading a dummy
>> bpf_prog on the netdev? (then we need to handle 1. not replacing
>> existing bpf_prog, 2. on take-down don't remove "later" loaded
>> bpf_prog).
> 
> right. these things need to be taken care of.
> Technically for ndo_xdp_xmit to work the program doesn't need
> to be attached, but the device needs to be in xdp mode with
> configured xdp tx rings.
> The easiest, of course, is just to document it :)
> and may be add some sort of warning that if netdev is added
> to devmap and it's not in xdp mode, return warning or error.
> 

When I wrote this I assumed some user space piece could
load the "dummy" nop program on devices as needed. It seemed
easier than putting semi-complex logic in the kernel to load
programs on update_elem, but only if the user hasn't already
loaded a program and then unload it but again only if some
criteria is met. Then we would have one more kernel path into
load/unload BPF programs and would need all the tests and what
not.

+1 for documenting and userland usability patches.

.John
