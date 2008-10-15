From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 rx errors printing to the console
Date: Wed, 15 Oct 2008 15:53:42 -0700
Message-ID: <20081015155342.3deba033@speedy>
References: <76366b180810150640h230ee681wd9cb474dbe4c7045@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Andrew Paprocki" <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42896 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbYJOWxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 18:53:44 -0400
In-Reply-To: <76366b180810150640h230ee681wd9cb474dbe4c7045@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Oct 2008 14:40:58 +0100
"Andrew Paprocki" <andrew@ishiboo.com> wrote:

> sky2 eth0: rx error, status 0xba0202 length 186
> sky2 eth0: rx error, status 0xba0220 length 186
> sky2 eth0: rx error, status 0xba0202 length 186
> sky2 eth0: rx error, status 0xba0202 length 186
> sky2 eth0: rx error, status 0x1390202 length 313
> sky2 eth0: rx error, status 0x1680202 length 360
> sky2 eth0: rx error, status 0xba0202 length 186
> sky2 eth0: rx error, status 0xf40202 length 244
> sky2 eth0: rx error, status 0xba0202 length 186

The status field is:
   
    +------------+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |0 length    | | | | | | | | | | | | | | |
    +------------+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
                  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
                  | | | | | | | | | | | | | +- Rx FIFO Overflow
                  | | | | | | | | | | | | +--- CRC Error
                  | | | | | | | | | | | +----- 
                  | | | | | | | | | | +------- Fragment
                  | | | | | | | | | +--------- Too Long
                  | | | | | | | | +----------- MII Error
                  | | | | | | | +------------- Bad flow control
                  | | | | | | +--------------- Good flow control
                  | | | | | +----------------- Rx Ok
                  | | | | +------------------- Broadcast
                  | | | +--------------------- Multicast
                  | | +----------------------- Runt
                  | +------------------------ Jabber
                  +------------------------- VLAN

Your packets have ehtther CRC error or MII Error set
