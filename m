From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: zd1211rw and mac80211: multicast/v6 doesn't work in 2.6.21.5
Date: Tue, 31 Jul 2007 11:27:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707311124560.8287@netcore.fi>
References: <Pine.LNX.4.64.0706280814090.21541@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:57749 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbXGaI1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 04:27:25 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id l6V8RMfl008548
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 11:27:23 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id l6V8RMSA008545
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 11:27:22 +0300
In-Reply-To: <Pine.LNX.4.64.0706280814090.21541@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FWIW,

multicast/v6 is still broken on zd1211rw on 2.6.22.1 based Fedora 7 
kernel (2.6.22.1-33.fc7).

On Thu, 28 Jun 2007, Pekka Savola wrote:
> On Fedora 7 (kernel 2.6.21-1.3228.fc7, based on 2.6.21.5), my 
> zd1211rw_mac80211 WLAN USB stick and multicast/v6 no longer works. On Fedora 
> 6 (kernel 2.6.20, no mac80211) it was OK.
>
> I get "wlan0: duplicate address detected!" on dmesg when the kernel is trying 
> to autoconfigure a global address.
>
> I suppose this is caused by the IPv6 stack seeing my own ICMPv6 neighbor 
> solicitation and thinking it was originated by someone else:
>
> 08:46:21.762807 00:02:72:5b:dc:28 > 33:33:ff:5b:dc:28, ethertype IPv6 
> (0x86dd), length 78: (hlim 255, next-header: ICMPv6 (58), length: 24) :: > 
> ff02::1:ff5b:dc28: [icmp6 sum ok] ICMP6, neighbor solicitation, length 24, 
> who has 2001:708:10:90:202:72ff:fe5b:dc28
>
> Strangely, the same error isn't printed with the link-local address which 
> uses the same EUI-64.
>
> z1211rw Wiki seems to imply that this might be an issue in generic mac80211 
> code:
>
> http://www.linuxwireless.org/en/users/Drivers/zd1211rw/mac80211Issues
>
> It'd be nice to get this fixed.  Or has it already been?
>
>

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
