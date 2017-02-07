From: Stafford Horne <shorne@gmail.com>
Subject: Re: [PATCH 1/2] libceph: Remove unneeded stddef.h include
Date: Tue, 7 Feb 2017 11:45:45 +0900
Message-ID: <20170207024545.GH32144@lianli.shorne-pla.net>
References: <cover.1486276931.git.shorne@gmail.com>
 <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB027CAAA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Ilya Dryomov <idryomov@gmail.com>,
        "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027CAAA@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 06, 2017 at 04:16:55PM +0000, David Laight wrote:
> From: Stafford Horne
> > Sent: 05 February 2017 07:08
> > This was causing a build failure for openrisc when using musl and
> > gcc 5.4.0 since the file is not available in the toolchain.
> > 
> > It doesnt seem this is needed and removing it does not cause any build
> > warnings for me.
> 
> Hmmm... stddef.h is part of the SuS v2.
> Required to get definitions for NULL, offsetof(), ptrdiff_t and size_t.
> 
> So any system that is pretending to by unix-like ought to have one.

Hello,
I agree, and also I can see that musl and gcc both do provide it.  I am
not sure why its not getting included for kernel builds, I didnt look
into it much because on the other hand...

Linux also provides it in 'linux/stddef.h'.  In this case vchiq_shim.c
includes "vchiq_util.h".
  which includes "linux/string.h"
    which includes "linux/stddef.h"

So the requirement seems satisfied.

I am fine to send a patch to change the include to <linux/stddef.h> as I
mentioned in the cover letter.  But I dont think its really needed.

-Stafford
