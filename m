From: Luca Coelho <luca@coelho.fi>
Subject: Re: [GIT] Networking
Date: Thu, 07 Sep 2017 08:40:51 +0300
Message-ID: <1504762851.5400.93.camel@coelho.fi>
References: <20170905.214143.826912481689443792.davem@davemloft.net>
         <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
         <1504757495.5400.89.camel@intel.com>
         <CA+55aFzECjnpFWo_ZfbV+vE-5zRst7JfDC0hxnoitCGN0rmE3Q@mail.gmail.com>
         <1504760688.5400.91.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linuxwifi <linuxwifi@intel.com>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504760688.5400.91.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-09-07 at 05:04 +0000, Coelho, Luciano wrote:
> On Wed, 2017-09-06 at 21:57 -0700, Linus Torvalds wrote:
> > On Wed, Sep 6, 2017 at 9:11 PM, Coelho, Luciano
> > <luciano.coelho@intel.com> wrote:
> > > 
> > > This seems to be a problem with backwards-compatibility with FW version
> > > 27.  We are now in version 31[1] and upgrading will probably fix that.
> > 
> > I can confirm that fw version 31 works.
> 
> Great, so I know for sure that this is a backwards-compatibility issue
> with the FW API.
> 
> 
> > > But obviously the driver should not fail miserably like this with
> > > version 27, because it claims to support it still.
> > 
> > Not just "claims to support it", but if it's what is shipped with a
> > fairly recent distro like an up-to-date version of F26, I would really
> > hope that the driver can still work with it.
> 
> I totally agree, we support a bunch of older versions for that exact
> reason.  We just don't really test all the supported versions very
> often.  We should probably change that.
> 
> I'll make sure it still works with version 27.

Okay, I found the offending patch:

commit 7089ae634c50544b29b31faf1a751e8765c8de3b
Author:     Johannes Berg <johannes.berg@intel.com>
AuthorDate: Wed Jun 28 16:19:49 2017 +0200
Commit:     Luca Coelho <luciano.coelho@intel.com>
CommitDate: Wed Aug 9 09:15:32 2017 +0300

    iwlwifi: mvm: use firmware LED command where applicable
    
    On devices starting from 8000 series, the host can no longer toggle
    the LED through the CSR_LED_REG register, but must do it via the
    firmware instead. Add support for this. Note that this means that
    the LED cannot be turned on while the firmware is off, so using an
    arbitrary LED trigger may not work as expected.
    
    Fixes: 503ab8c56ca0 ("iwlwifi: Add 8000 HW family support")
    Signed-off-by: Johannes Berg <johannes.berg@intel.com>
    Signed-off-by: Luca Coelho <luciano.coelho@intel.com>

Reverting it solves the problem.  We introduced a new command to control
the LED lights and assumed it was available in older FW versions as
well, which turned out not to be the case.

This patch is not very important (unless you really like blinking lights
-- maybe I'll change my mind when the holidays approach :P). so it is
fine if you just want to revert it for now.

In any case, I'll send a patch fixing this problem soon.


--
Cheers,
Luca.
