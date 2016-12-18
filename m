From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sun, 18 Dec 2016 01:15:07 +0100
Message-ID: <20161218001507.GA5343@electric-eye.fr.zoreil.com>
References: <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
 <20161217173150.GA20231@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161217173150.GA20231@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> :
[...]
> Won't this up/down the interface, in a way userspace can observe?

It won't up/down the interface as it doesn't exactly mimic what the
network code does (there's more than rtnl_lock).

For the same reason it's broken if it races with the transmit path: it
can release driver resources while the transmit path uses these.

Btw the points below may not matter/hurt much for a proof a concept
but they would need to be addressed as well:
1) unchecked (and avoidable) extra error paths due to stmmac_release()
2) racy cancel_work_sync. Low probability as it is, an irq + error could
   take place right after cancel_work_sync

Lino, have you considered via-rhine.c since its "move work from irq to
workqueue context" changes that started in
7ab87ff4c770eed71e3777936299292739fcd0fe [*] ?

It's a shameless plug - originated in r8169.c - but it should be rather
close to what the sxgbe and friends require. Thought / opinion ?

[*] Including fixes/changes in:
- 3a5a883a8a663b930908cae4abe5ec913b9b2fd2
- e1efa87241272104d6a12c8b9fcdc4f62634d447
- 810f19bcb862f8889b27e0c9d9eceac9593925dd
- e45af497950a89459a0c4b13ffd91e1729fffef4
- a926592f5e4e900f3fa903298c4619a131e60963
- 559bcac35facfed49ab4f408e162971612dcfdf3

-- 
Ueimor
