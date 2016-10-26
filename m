From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 20:21:24 -0600
Message-ID: <fdeb1f5b-d122-36d8-4866-42cb5f29f0e2@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <1477438787.7065.158.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36000 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcJZCV2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 22:21:28 -0400
Received: by mail-pf0-f175.google.com with SMTP id e6so129569726pfk.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 19:21:27 -0700 (PDT)
In-Reply-To: <1477438787.7065.158.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 5:39 PM, Eric Dumazet wrote:
> On Tue, 2016-10-25 at 15:30 -0700, David Ahern wrote:
>> Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
>> BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
>> any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
>> Currently only sk_bound_dev_if is exported to userspace for modification
>> by a bpf program.
>>
>> This allows a cgroup to be configured such that AF_INET{6} sockets opened
>> by processes are automatically bound to a specific device. In turn, this
>> enables the running of programs that do not support SO_BINDTODEVICE in a
>> specific VRF context / L3 domain.
> 
> Does this mean that these programs no longer can use loopback ?

I am probably misunderstanding your question, so I'll ramble a bit and see if I cover it.

This patch set generically allows sk_bound_dev_if to be set to any value. It does not check that an index corresponds to a device at that moment (either bpf prog install or execution of the filter), and even if it did the device can be deleted at any moment. That seems to be standard operating procedure with bpf filters (user mistakes mean packets go no where and in this case a socket is bound to a non-existent device).

The index can be any interface (e.g., eth0) or an L3 device (e.g., a VRF). Loopback and index=1 is allowed.

The VRF device is the loopback device for the domain, so binding to it covers addresses on the VRF device as well as interfaces enslaved to it.

Did you mean something else?
