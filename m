From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv5 iproute2 net-next 2/2] lib/libnetlink: re malloc buff if
 size is not enough
Date: Thu, 26 Oct 2017 09:28:00 -0600
Message-ID: <25f0ec07-e36a-510c-c01f-56df8a843f80@gmail.com>
References: <1508982107-28474-1-git-send-email-liuhangbin@gmail.com>
 <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
 <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
 <20171026122442.7e2ac2d0@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:52284 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932246AbdJZP17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:27:59 -0400
Received: by mail-pf0-f195.google.com with SMTP id e64so2747338pfk.9
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:27:59 -0700 (PDT)
In-Reply-To: <20171026122442.7e2ac2d0@shemminger-XPS-13-9360>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 4:24 AM, Stephen Hemminger wrote:
>>
>> The kernel needs a flag that says "give me the message of the buffer is
>> large enough; if not just PEEK and tell me the length." That would avoid
>> the double call in most cases.
> 
> Actually this has little impact because old code was doing implicit zero
> of whole buffer, new code does not.
> 

The patch calls recvmsg twice; libnl does the same thing. It would be
better performance wise to have a flag that allows retrieval of the
message if the supplied buffer is large enough and PEEK semantics if
not. It was really a comment on how we could do better with proper
kernel support.
