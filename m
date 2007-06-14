From: "C. Scott Ananian" <cscott@laptop.org>
Subject: Handling IPv6 RDNSS in RA
Date: Thu, 14 Jun 2007 18:27:38 -0400
Message-ID: <c6d9bea0706141527i72c82819r95341fc7fb08c1c4@mail.gmail.com>
References: <c6d9bea0706141307v6101719s1d8c2761ba1be392@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "David Woodhouse" <dwmw2@infradead.org>, marcelo@kvack.org,
	dcbw@redhat.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	jjeong@cs.umn.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:27116 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbXFNW1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 18:27:39 -0400
Received: by an-out-0708.google.com with SMTP id d31so152030and
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 15:27:38 -0700 (PDT)
In-Reply-To: <c6d9bea0706141307v6101719s1d8c2761ba1be392@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Re-sending an earlier email, this time with a wider distribution and
more details.]

I'd like to get opinions on how DNS information packaged with IPv6
Router Advertisement packages should be handled.  The OLPC project
(laptop.org) is currently planning to use this for DNS
autoconfiguration.  The draft RFC is at:
    http://tools.ietf.org/html/draft-jeong-dnsop-ipv6-dns-discovery-12
There is already code in radvd to support this.  [For reference, the
Router Advertisement (RA) option is called RDNSS, for 'Recursive DNS
Server'.]

Two alternatives seem obvious:
  1) Parse the RDNSS option in the kernel.  linux/net/ipv6/ndisc.c
already parses the other RAdv options; it just need to be extended to
parse RDNSS and export the 'last seen DNS conf' in the same way it
does the Managed/Other flags at
     http://lxr.linux.no/source/net/ipv6/ndisc.c?v=2.6.20.1#L1115
[Incidentally, I suspect I can get at the Managed/Other flags via
netlink, but would appreciate advice.]

 2) Parse the RDNSS information entirely in userspace.  The
NetworkManager(1) daemon would keep a socket open to listen to all
ICMPv6 messages, reparse the RA, and deal with RDNSS information.
This has the disadvantage of requiring redundant tracking of RA
lifetimes, and would require NetworkManager to send (likely redundant)
Router Solicitation messages when/if the RDNSS information expires.

Option 2 seems like duplication of work, but arguably keeps the kernel
small.  Honestly, I'm surprised that IPv6 autoconfiguration is in the
kernel at all.  But since it's there already, option 1's making RDNSS'
3*(128/8) bytes available via netlink doesn't seem too terrible to me.
 But if such a patch has no hope of being accepted into the mainline
kernel, I'd rather know now than later.

Also: are there other implementations which use the RA DNS info?
Maybe in fact someone has already written the necessary kernel patch?
I always prefer not to reinvent the wheel.
  --scott

-- 
                         ( http://cscott.net/ )
