From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 09:57:33 -0600
Message-ID: <56211E6D.4070507@cumulusnetworks.com>
References: <cover.1444926905.git.jbenc@redhat.com>
 <20151015.235007.973370825335101214.davem@davemloft.net>
 <20151016093945.54a6a7aa@griffin>
 <20151016.010644.2090038835491896678.davem@davemloft.net>
 <20151016100221.6fd5034f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35933 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932677AbbJPP5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 11:57:36 -0400
Received: by pacfv9 with SMTP id fv9so26377688pac.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 08:57:35 -0700 (PDT)
In-Reply-To: <20151016100221.6fd5034f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 2:02 AM, Jiri Benc wrote:
> On Fri, 16 Oct 2015 01:06:44 -0700 (PDT), David Miller wrote:
>> No, it's definitely not OK, because lwtunnel support exists in
>> Linus's tree.
>>
>> And tools should be able to work on all kernels where lwtunnel support
>> is available.
>
> You can consider the lwtunnels feature as not finished in the current
> Linus's tree. It works, it won't change (thus anything using it in its
> current form will continue to work in all the future kernels), but
> mainstream tools won't make use of it until a kernel version later
> which will get some additional support.
>
> I don't think it's much of a problem and I don't think it is the first
> time this would happen.
>
> I'm afraid I don't have any solution that could do better.

What about a flag that requests the version from the relevant kernel 
subsystem?

Generate the same initial netlink message -- e.g., type set to 
RTM_NEWROUTE for example -- but with no attributes and the NLM_F_VERSION 
flag set. Send the message using whatever socket protocol is relevant 
for the command/query.

Then kernel side the message makes its way to the relevant handler, the 
handler sees the flag asking for version and responds with its version. 
The version would be local to the handler and is a means for telling 
userspace what attributes it understands.
