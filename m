From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 03:03:34 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.030334.02284330.davem@redhat.com>
References: <20030609081803.GF20613@netnation.com>
	<20030609.020116.10308258.davem@redhat.com>
	<20030609094734.GD2728@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se
Return-path: <linux-net-owner@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20030609094734.GD2728@wotan.suse.de>
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Mon, 9 Jun 2003 11:47:34 +0200
   
   gcc will generate a lot better code for the memsets if you can tell
   it somehow they are long aligned and a multiple of 8 bytes.

True, but the real bug is that we're initializing any of this
crap here at all.  Right now we write over the same cachelines
3 or so times.  It should really just happen once.
