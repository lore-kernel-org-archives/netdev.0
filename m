From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 18:01:41 +0100
Message-ID: <20071113170141.GD4250@stusta.de>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <4739C1B0.8000803@cateee.net> <2c0942db0711130757g295add20re0ee423b84921d28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Giacomo A. Catenazzi" <cate@cateee.net>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2c0942db0711130757g295add20re0ee423b84921d28@mail.gmail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 07:57:54AM -0800, Ray Lee wrote:
> On Nov 13, 2007 7:24 AM, Giacomo A. Catenazzi <cate@cateee.net> wrote:
> > As a long time kernel tester, I see some problem with the
> > newer "new development model". In the short merge windows,
> > after to much time, there are to many patches.
> 
> I think the root issue there is that it's hard to get all testers to
> run a bisect, but easy to ask them to test snapshots. Right now the
> snapshots are generated nightly, but I think it would make more sense
> if they were generated every N patches, for some value of N...
>...

I don't see a point in doing that - that would be a more manual 
bisecting, and the result would not be one guilty commit.

Testers are not expected to be able to hack a kernel, but it's 
reasonable to expect testers to be able to build their own kernels
(and your proposal wouldn't change that).

The small instruction below is enough for everyone who is able to 
build his own kernel to do a git bisect.

> Ray

cu
Adrian


<--  snip  -->


# install git

# clone Linus' tree:
git clone \ 
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

# start bisecting:
cd linux-2.6
git bisect start
git bisect bad v2.6.21
git bisect good v2.6.20
cp /path/to/.config .

# start a round
make oldconfig
make
# install kernel, check whether it's good or bad, then:
git bisect [bad|good]
# start next round


After at about 10-15 reboots you'll have found the guilty commit
("...  is first bad commit").


More information on git bisecting:
  man git-bisect

