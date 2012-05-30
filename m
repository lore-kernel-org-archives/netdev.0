From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 30 May 2012 13:59:11 +0200
Message-ID: <1338379151.2760.166.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	 <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
	 <20120530090602.6204d857.shimoda.hiroaki@gmail.com>
	 <1338367231.2760.125.camel@edumazet-glaptop>
	 <20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>
	 <1338376107.2760.156.camel@edumazet-glaptop>
	 <1338376817.32113.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34551 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab2E3L7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 07:59:17 -0400
Received: by bkcji2 with SMTP id ji2so4021435bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 04:59:15 -0700 (PDT)
In-Reply-To: <1338376817.32113.5.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 04:20 -0700, Joe Perches wrote:
> On Wed, 2012-05-30 at 13:08 +0200, Eric Dumazet wrote:
> > Maybe we should change all POSDIFF(), not selected ones.
> > #define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
> 
> maybe use an eval once statement expression macro
> ({
> 	typeof (A) _a = (A);
> 	typeof (B) _b = (B);
> 	((int)(_a - _b) > 0 ? _a - _b : 0;
> })
> 
> 

Well, many choices are possible, including

#define POSDIFF(A, B) max_t(int, (A) - (B), 0);
