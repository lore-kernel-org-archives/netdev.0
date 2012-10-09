From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH] compat-drivers: update ethernet driver alx in crap dir
Date: Mon, 8 Oct 2012 18:14:01 -0700
Message-ID: <CAB=NE6WL0FS+FHSZ-naHnqvO_DTRnobkX_Yp4J_rxM2Kkge7Ag@mail.gmail.com>
References: <1349400892-25315-1-git-send-email-xiong@qca.qualcomm.com>
 <CAB=NE6VotAu-cugsn4==3TPX0OGPEFtdn1J+5+Rd_YfLcg9YDQ@mail.gmail.com> <20121009004209.GC9068@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: xiong@qca.qualcomm.com, mcgrof@kernel.org,
	backports@vger.kernel.org, nic-devel@qualcomm.com,
	Ren Cloud <cjren@qca.qualcomm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	qca_vkondrat@qca.qualcomm.com
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121009004209.GC9068@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 8, 2012 at 5:42 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Mon, Oct 08, 2012 at 03:25:08PM -0700, Luis R. Rodriguez wrote:
>> On Thu, Oct 4, 2012 at 6:34 PM,  <xiong@qca.qualcomm.com> wrote:
>> > From: xiong <xiong@qca.qualcomm.com>
>> >
>> > 1. support new device id (0x10A0/0x10A1).
>> > 2. add DEBUG_FS interface for diag/swoi functions.
>> >
>> > Signed-off-by: Ren Cloud <cjren@qca.qualcomm.com>
>> > Signed-off-by: xiong <xiong@qca.qualcomm.com>
>>
>> Xiong,
>>
>>  -- Vladimir, just a heads up -- this applies to you as well for the
>> 802.11ad wil6210 driver
>>  -- Greg, some review on your preference on this would be appreciated
>
> Preference on what?  I've never seen this driver before, why wasn't it
> submitted to be in the staging tree in the first place?

Because the goal was to jump straight to proper upstream and this was
expected to happen rather easily.

>> The original alx crap patch was added into compat-wireless on the
>> linux-3.5.y branch.
>
> What is "crap patch"?  And is this the old driver with the dubios
> history keeping it from ever being merged anywhere, or is this something
> new?

The driver never had any legal dubious issues. The issues with the alx
driver were purely technical.

>> Its been two kernel releases and alx is not yet
>> upstream and users can only get alx via compat-drivers (technically
>> compat-wireless as that was pre v3.7). v3.7 would be the *third*
>> release in which this would happen... This is unfair to users and
>> consumers of the Linux kernel and derails expectations and our
>> arrangements for Linux kernel development. I realize that the goal was
>> to get alx upstream ASAP but regardless of what the reason is, its not
>> yet upstream. If you cannot work on alx on a timely manner to get
>> upstream then please submit the driver to the staging area of the
>> Linux kernel that Greg maintains so that other developers who may be
>> able to help can submit patches to help you. Under staging your driver
>> should be accepted so long as it compiles.
>>
>> I will update the documentation for crap/ patches for compat-drivers
>> to make it clear now that crap/ patches can be used for adding
>> components / pieces of code not yet ready for upstream but as far as
>> full new drivers are concerned you only get one kernel release cycle
>> for it to linger on crap/ under compat-drivers, if you haven't
>> addressed upstreaming yet then it should go to drivers/staging/. That
>> is crap/ should only be used as a shortcut because users exist that
>> can use the driver but you *do* have a team properly resourced to
>> address upstreaming properly in a timely manner.
>
> Why do you even need crap/ at all?  What is keeping drivers like this
> (if it isn't the legally dubious driver) from being merged into staging
> today?  And if it is the legally dubious driver, well, you had better
> not be taking it in your tree either...

crap/ was invented for patches to existing code that people wrote that
they for whatever reason did not think would ever get upstream but yet
they *needed* to support for customer deliveries. Consider a feature
that won't be acceptable but yet a customer *needs* today. In such
case we know the developer should post it as it will get rejected. The
developer may also know that they have to adjust the code to meet
upstream criteria, and they might do that in 1 or 2 future kernel
releases. Without having a mechanism to allow these type of patches
folks go on a forking bandwagon and at times creates a slippery slope
to never go back upstream.

crap/ then was used later for alx as a full driver rather than
drivers/staging/ given that the developers believed they could address
upstream concerns within a release cycle and they needed a release
ASAP. The alx driver needed to be changed to remove atl1c device
support as per review and only support new generation devices. It was
a lot easier for the developers to address that internally rather than
working on drivers/staging. In the end alx is still not upstream as
more technical issues have have not yet been addressed.

I'm considering perhaps just not allowing full drivers through crap/
on compat-drivers and simply having developers bite the bullet and
have to go through staging if they really need a release ASAP and are
not yet ready for upstream.

At this point I am revisiting the policy of when / if to allow drivers
at all through crap/ and that's what I was asking for review for.

  Luis
