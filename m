From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: Bonding with tun-devices
Date: Wed, 21 May 2014 17:55:23 +0200
Message-ID: <537CCC6B.60909@redhat.com>
References: <537CB13A.3030100@markas-al-nour.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linus Gasser <list@markas-al-nour.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbaEUQvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 12:51:08 -0400
In-Reply-To: <537CB13A.3030100@markas-al-nour.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/2014 03:59 PM, Linus Gasser wrote:
> Dear list,
> 
> I'm trying to create a bonded interface using tun-devices created by the
> 
> ssh -NTCf -w 0:0
> 
> command. The reason is that I'm behind a satellite connection with per-stream
> limited bandwidth...
> 
> On some older kernels everything was fine, and I could do:
> 
> # ssh -NTCf -w 0:0 web
> # ssh -NTCf -w 1:1 web
> # modprobe bonding mode=0 miimon=100
> # ifconfig bond0 172.16.0.1 netmask 255.255.255.0
> # ifconfig bond0 hw ether 12:34:56:78:9a
> # ifenslave bond0 tun0 tun1
> 
> on one side and
> 
> # modprobe bonding mode=0 miimon=100
> # ifconfig bond0 172.16.0.2 netmask 255.255.255.0
> # ifconfig bond0 hw ether 12:35
> # ifenslave -f bond0 tun0 tun1
> # ping 172.16.0.1
> 
> on the other side. On a newer kernel (>3.14) this doesn't work (at least not on
> linux-armv7), while on 3.13 it does work under linux-armv7. Now I've been told
> to use the iproute2-suite, as ifenslave is deprecated. But if I try to do
> 
> # ssh -NTCf -w 0:0 web
> # ssh -NTCf -w 1:1 web
> # ip link add name bond1 type bond
> # ip link set dev tun0 master bond1
> 
> it gives me an error
> 
> RTNETLINK answers: Operation not supported
> 
> Any idea what I'm doing wrong?
> 
> Linus
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Hi,
Could you please try modprobe bonding mode=0 miimon=100 fail_over_mac=active ?
I know that fail_over_mac doesn't affect that mode, but I think I can see why
it's happening.

Cheers,
 Nik
