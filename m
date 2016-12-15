From: "Du, Fan" <fan.du@intel.com>
Subject: Re: [Query] Delayed vxlan socket creation?
Date: Thu, 15 Dec 2016 16:43:58 +0800
Message-ID: <585257CE.6040004@intel.com>
References: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com> <CAM_iQpXujwj_GcN5KOT4vMbPj-H+B+=MdPjpRWZZrc+piooBYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mrjana@gmail.com" <mrjana@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40721 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757523AbcLOIy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 03:54:27 -0500
In-Reply-To: <CAM_iQpXujwj_GcN5KOT4vMbPj-H+B+=MdPjpRWZZrc+piooBYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



在 2016年12月15日 01:24, Cong Wang 写道:
> On Tue, Dec 13, 2016 at 11:49 PM, Du, Fan <fan.du@intel.com> wrote:
>> Hi
>>
>> I'm interested to one Docker issue[1] which looks like related to kernel vxlan socket creation
>> as described in the thread. From my limited knowledge here, socket creation is synchronous ,
>> and after the *socket* syscall, the sock handle will be valid and ready to linkup.
> You need to read the code. vxlan tunnel is a UDP tunnel, it needs a kernel
> socket (and a port) to setup UDP communication, unlike GRE tunnel etc.
I check the fix is merged in 4.0, my code base is pretty new,
so somehow I failed to see the work queue stuff in drver/net/vxlan.c
>> Somehow I'm not sure the detailed scenario here, and which/how possible commit fix?
>> Thanks!
>>
>> Quoted analysis:
>> --------------------------------------------------------------------------
>> (Found in kernel 3.13)
>> The issue happens because in older kernels when a vxlan interface is created,
>> the socket creation is queued up in a worker thread which actually creates
>> the socket. But this needs to happen before we bring up the link on the vxlan interface.
>> If for some chance, the worker thread hasn't completed the creation of the socket
>> before we did link up then when we do link up the kernel checks if the socket was
>> created and if not it will return ENOTCONN. This was a bug in the kernel which got fixed
>> in later kernels. That is why retrying with a timer fixes the issue.
>
> This was introduced by commit 1c51a9159ddefa5119724a4c7da3fd3ef44b68d5
> and later fixed by commit 56ef9c909b40483d2c8cb63fcbf83865f162d5ec.
信聪哥，得永生。
Thanks for the offending commit id！
