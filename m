From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: UDP does not autobind on recv
Date: Mon, 24 Oct 2016 16:23:00 +0200
Message-ID: <fc4ce236-7f34-601a-79f0-7ac9e087e7f9@suse.cz>
References: <5d0f78b4-f850-4f73-dbb7-6c3d15d99c86@suse.cz>
 <1477314180.7065.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ML netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35533 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941123AbcJXOXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 10:23:03 -0400
Received: by mail-wm0-f44.google.com with SMTP id c78so107086126wme.0
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 07:23:02 -0700 (PDT)
In-Reply-To: <1477314180.7065.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2016, 03:03 PM, Eric Dumazet wrote:
> On Mon, 2016-10-24 at 14:54 +0200, Jiri Slaby wrote:
>> Hello,
>>
>> as per man 7 udp:
>>   In order to receive packets, the socket can be bound to
>>   a local  address first  by using bind(2).  Otherwise,
>>   the socket layer will automatically assign a free local
>>   port out of the range defined by /proc/sys/net/ipv4
>>   /ip_local_port_range and bind the socket to INADDR_ANY.
>>
>> I did not know that bind is unneeded, so I tried that. But it does not
>> work with this piece of code:
>> int main()
>> {
>>     char buf[128];
>>     int fd = socket(AF_INET, SOCK_DGRAM, 0);
>>     recv(fd, buf, sizeof(buf), 0);
>> }
> 
> autobind makes little sense at recv() time really.
> 
> How an application could expect to receive a frame to 'some socket'
> without even knowing its port ?

For example
        struct sockaddr_storage sa;
        socklen_t slen = sizeof(sa);
        recv(fd, buf, sizeof(buf), MSG_DONTWAIT);
        getsockname(fd, (struct sockaddr *)&sa, &slen);
        recv(fd, buf, sizeof(buf), 0);
works.

> How useful would that be exactly ?

No need for finding a free port and checking, for example.

> How TCP behaves ?

TCP is a completely different story. bind is documented to be required
there. (And listen and accept.)

> I would say, fix the documentation if it is not correct.

I don't have a problem with either. I have only found, that the
implementation differs from the documentation :). Is there some
supervisor documentation (like POSIX) which should we be in conformance to?

thanks,
-- 
js
suse labs
