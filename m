From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 08:36:59 -0700
Message-ID: <1471966619.14381.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
         <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <1471964716.3746.103.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Luis Henriques <luis.henriques@canonical.com>,
        Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471964716.3746.103.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 08:05 -0700, Joe Perches wrote:

> A compiler does not have a standards based requirement to
> initialize arbitrary padding bytes.
> 
> I believe gcc always does zero all padding anyway.

I would not worry for kernel code, because the amount of scrutiny there
will be enough to 'fix potential bugs' [1], but a lot of user land code
would suffer from various bugs as well that might sit there forever.

[1] Also, most call sites in the kernel are using same call stack, so
the offset of '1-7 leaked bytes' vs kernel stack is constant, making
exploits quite challenging.

Even if the current standards are lazy (are they, I did not check ?),
security needs would call for a sane compiler behavior and changing the
standards accordingly.
