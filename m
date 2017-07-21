From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: commit 16ecba59 breaks 82574L under heavy load.
Date: Fri, 21 Jul 2017 11:27:09 -0400
Message-ID: <20170721152709.GT18556@csclub.uwaterloo.ca>
References: <20170718142109.GO18556@csclub.uwaterloo.ca>
 <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
 <20170719141953.GQ18556@csclub.uwaterloo.ca>
 <20170720000747.4jiadqubv7hg5esz@f1.synalogic.ca>
 <20170720140027.GR18556@csclub.uwaterloo.ca>
 <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2017 at 04:44:55PM -0700, Benjamin Poirier wrote:
> Could you please test the following patch and let me know if it:
> 1) reduces the interrupt rate of the Other msi-x vector
> 2) avoids the link flaps
> or
> 3) logs some dmesg warnings of the form "Other interrupt with unhandled [...]"
> In this case, please paste icr values printed.

I will give it a try.

Another odd behaviour I see is that the driver will hang in
napi_synchronize on shutdown if there is traffic at the time (at least
I think that's the trigger, maybe the trigger is if there has been an
overload of traffic and the backlog in napi was used).

>From doing some searching, this seems to be a problem that has plagued
some people for years with this driver.

I am having trouble figuring out exactly what napi_synchronize is waiting
for and who is supposed to toggle the flag it is waiting on.  The flag
appears to work backwards from what I would have expected it to do.
I see lots of places that can set the bit, but only napi_enable seems
to clear it again, and I don't see how that would get called for all
the places that potentially set the bit.

-- 
Len Sorensen
