From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: SO_BINDTODEVICE in VRFs not working?
Date: Fri, 17 Mar 2017 23:54:12 -0600
Message-ID: <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
References: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
To: Daniele Orlandi <daniele@orlandi.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35685 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbdCRGEM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 02:04:12 -0400
Received: by mail-it0-f50.google.com with SMTP id m27so43307906iti.0
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 23:03:03 -0700 (PDT)
In-Reply-To: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/17 7:59 PM, Daniele Orlandi wrote:
> 
> Hello,
> 
> I'm writing an application that should listen on a TCP port bound to an
> inteface in a VRF.
> 
> The bind/listen sequence is the following:
> 
>   int s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
> 
>   char *ifname = "eth1";

Bind to the VRF device not an interface enslaved to it. I want to add
the option for enslaved interfaces but have not gotten around to it.


>   setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, ifname, strlen(ifname)+1);
> 
>   struct sockaddr_in addr;
>   memset(&addr, 0, sizeof addr);
>   addr.sin_family = AF_INET;
>   addr.sin_port = htons(555);
>   addr.sin_addr.s_addr = inet_addr("0.0.0.0");
> 
>   bind(s, (struct sockaddr *)&addr, sizeof(addr));
> 
>   listen(s, 5);
> 
> The application is confirmed to be bound to the correct interface via "ss":
> 
> Netid State    Local Address:Port     Peer Address:Port
> tcp   LISTEN   *%eth1:555             *:*
> 
> I can ping the interface address finely, however I get an RST whenever I
> try to connect from a remote host:
> 
> $ ping 10.10.10.10
> PING 10.10.10.10 (10.10.10.10) 56(84) bytes of data.
> 64 bytes from 10.10.10.10: icmp_seq=1 ttl=64 time=0.758 ms
> 64 bytes from 10.10.10.10: icmp_seq=2 ttl=64 time=0.350 ms
> 
> $ telnet 10.10.10.10 555
> Trying 10.10.10.10...
> telnet: Unable to connect to remote host: Connection refused
> 
> A similar piece of code without setsockopt run via "ip vrf exec" does
> however work!

'ip vrf exec' binds sockets to the VRF.
