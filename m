From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Query regarding pf_packet sockets
Date: Wed, 21 Mar 2012 21:28:42 -0700
Message-ID: <1332390522.9433.17.camel@edumazet-glaptop>
References: <B97B134FACB2024DB45F524AB0A7B7F2063EB8C6@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:64156 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab2CVE2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 00:28:45 -0400
Received: by dajr28 with SMTP id r28so2547150daj.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 21:28:45 -0700 (PDT)
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2063EB8C6@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-22 at 08:52 +0530, Prashant Batra (prbatra) wrote:
> Hi ,
> 
> I am trying to use PF_PACKET socket along with filters applied on the socket through setsockopt, SO_ATTACH_FILTER.
> Now as I create this socket, any packet coming to the kernel would be copied into the socket buffer for this socket.
> 
> So, even if I apply the filter, first few packets would always be those which do not match the filter. 
> 
> Is there a way (some socket option),  to make socket passive and active, so that I will set the socket in passive mode after creation, 
> and then set it as active, after I apply the filter, so that I only receive the filtered packet in user space.
> 
> Thanks,
> Prashant
> 
1) open PF_PACKET
2)  Install a "deny all packets" filter
3) read all packets that might have been captured right before 2)
4) Install your filter

This is what is done by libpcap
