From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/4] Make xfrm usable by 32-bit programs
Date: Mon, 23 Jan 2017 16:45:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026BC58@AcuExch.aculab.com>
References: <20170121000507.34381-1-cernekee@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "selinux@tycho.nsa.gov" <selinux@tycho.nsa.gov>,
        "fw@strlen.de" <fw@strlen.de>,
        "fan.du@windriver.com" <fan.du@windriver.com>,
        "dianders@chromium.org" <dianders@chromium.org>,
        "dtor@chromium.org" <dtor@chromium.org>
To: 'Kevin Cernekee' <cernekee@chromium.org>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "paul@paul-moore.com" <paul@paul-moore.com>,
        "sds@tycho.nsa.gov" <sds@tycho.nsa.gov>,
        "eparis@parisplace.org" <eparis@parisplace.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170121000507.34381-1-cernekee@chromium.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kevin Cernekee
> Sent: 21 January 2017 00:05
> Several of the xfrm netlink and setsockopt() interfaces are not usable
> from a 32-bit binary running on a 64-bit kernel due to struct padding
> differences.  This has been the case for many, many years[0].  This
> patch series deprecates the broken netlink messages and replaces them
> with packed structs that are compatible between 64-bit and 32-bit
> programs.

Do you mean '__packed' or just structures with no holes?
The latter is really the best.
You can add a compile time assert on the structure sizes to ensure
that the user API is never accidentally broken.

I can't imagine any reason to change the 64bit structures except
(maybe) to make any padding explicit.

> It retains support for legacy user programs (i.e. anything
> that is currently working today), and allows legacy support to be
> compiled out via CONFIG_XFRM_USER_LEGACY if it becomes unnecessary in
> the future.
...

Isn't that effectively the same as doing a compat layer?
Otherwise you can't build a 32bit app that will work with an 'old'
32bit kernel and a new 64bit one.

Provided you've got the length of the user's buffer the compat code
ought to be trivial (if tedious).

	David
