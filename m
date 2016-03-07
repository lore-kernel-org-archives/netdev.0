From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Mon, 7 Mar 2016 12:09:52 -0700
Message-ID: <56DDD200.4080101@cumulusnetworks.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Gilberto Bertin <gilberto.bertin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35561 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcCGTJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:09:56 -0500
Received: by mail-io0-f172.google.com with SMTP id g203so142378940iof.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 11:09:55 -0800 (PST)
In-Reply-To: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/23/16 8:27 AM, Gilberto Bertin wrote:
> This series introduces support for the SO_BINDTOSUBNET socket option, which
> allows a listener socket to bind to a subnet instead of * or a single address.
>
> Motivation:
> consider a set of servers, each one with thousands and thousands of IP
> addresses. Since assigning /32 or /128 IP individual addresses would be
> inefficient, one solution can be assigning subnets using local routes
> (with 'ip route add local').
>
> This allows a listener to listen and terminate connections going to any
> of the IP addresses of these subnets without explicitly configuring all
> of them. This is very efficient.
>
> Unfortunately there may be the need to use different subnets for
> different purposes.
> One can imagine port 80 being served by one HTTP server for some IP
> subnet, while another server used for another subnet.
> Right now Linux does not allow this.
> It is either possible to bind to *, indicating ALL traffic going to
> given port, or to individual IP addresses.
> The first only allows to accept connections from all the subnets.
> The latter does not scale well with lots of IP addresses.

Have you looked at the VRF implementation?
     Documentation/networking/vrf.txt

It certainly handles some of your requirements -- e.g., create L3 
domains (VRFs) for subnets of interest. Apps can bind to the VRF device 
to provide service to only those networks in the domain.
