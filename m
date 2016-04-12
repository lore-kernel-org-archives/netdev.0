From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Inter-VRF routing on a single machine
Date: Tue, 12 Apr 2016 10:48:44 -0600
Message-ID: <570D26EC.2000802@cumulusnetworks.com>
References: <CAAJwJQkfVWkdL+tOvcu5C9XBwTpNKcB8qvGeDUO32Tq6nW=xMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Darwin Dingel <darwin.dingel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33605 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbcDLQsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 12:48:45 -0400
Received: by mail-io0-f179.google.com with SMTP id o126so36052191iod.0
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 09:48:44 -0700 (PDT)
In-Reply-To: <CAAJwJQkfVWkdL+tOvcu5C9XBwTpNKcB8qvGeDUO32Tq6nW=xMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/16 4:09 AM, Darwin Dingel wrote:
> Hi All,
>
> Have anyone tried the following setup on a single machine with 2 TCP
> sockets on different VRF's and succeeded?
>
> - client_socket on VRF1
> - server_socket on VRF2
> - ip rules and iproutes for inter-VRF set up
> - client_socket sends TCP connect to server_socket. skb was sent using
> VRF1 interface
> - skb received in loopback interface

That is the key problem there.

> - TCP code got SYN but cannot route back to VRF1 to send ACK.
>
> I was wondering if this is a known limitation of VRF as of the moment,
> or could work with proper iprules/iproute.

In general local (within a single system) routing does not work with top 
of tree. e.g., within a VRF you can not connect sockets or ping a VRF 
local address. Inter-vrf connections within a system also do not work.

I have patches from our 4.1 kernel that I have rebased to top of tree. I 
hope to test and send those out in the next week or so. It addresses the 
first problem -- connections within a VRF. While it does not resolve 
your problem of connecting across VRFs within a system I think it is the 
foundation for how to fix it.
