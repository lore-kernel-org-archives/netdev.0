From: "Shaw Vrana" <shawvrana@gmail.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Sat, 29 Apr 2006 14:57:28 -0700
Message-ID: <7bb8b8de0604291457i10474ceeudcea33ed93621045@mail.gmail.com>
References: <1145578214.3195.6.camel@rh4>
	 <20060421024024.GA29644@gondor.apana.org.au>
	 <1145582676.3195.18.camel@rh4>
	 <20060421132758.GA26161@gospo.rdu.redhat.com>
	 <1145633287.3194.10.camel@rh4>
	 <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
	 <1145646031.3843.5.camel@rh4>
	 <bdfc5d6e0604211346n50b15f56g4ebc2fe5fe88a63a@mail.gmail.com>
	 <7bb8b8de0604261714h2471420xa06bb6639ddb6cea@mail.gmail.com>
	 <44504EA7.5050901@foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Andy Gospodarek" <andy@greyhouse.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wproxy.gmail.com ([64.233.184.236]:20687 "EHLO wproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750812AbWD2V52 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 17:57:28 -0400
Received: by wproxy.gmail.com with SMTP id i11so372181wra
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2006 14:57:28 -0700 (PDT)
To: "Auke Kok" <sofar@foo-projects.org>
In-Reply-To: <44504EA7.5050901@foo-projects.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

On 4/26/06, Auke Kok <sofar@foo-projects.org> wrote:

> > I'm concerned about the addition of the netif_running check to
> > e1000_down.  While something like this is needed, I'm not familiar
> > enough w/ the code to know if this is okay.
> > All explanations and comments are greatly appreciated.
> While I appreciate patches ;^) I think we're on a better path by making these
> cleanups, and actually reducing the code in large places. I hope to be able to
> push something out for RFC soon. Added benefit will be that we're dropping a
> whole bunch of irq operations where we didn't need to (soft resets).

Well, it looks like my patch won't work as the e1000_close is called
by dev.c only after it clears the __LINK_STATE_START bit, which means
that e1000_down will exit prematurely when called from e1000_close in
my approach.  Any feedback on the approach would be appreciated, as
your upcoming patch sounds like it might be too aggressive to get put
into a stabilization patch.  ;)

I understand the need to fix the problems associated with the
watchdog_task as well, though I wonder if it wouldn't be better to
remove it altogether given the complexity of cleaning up after these
tasks in general.  I've personally had more problems with the watchdog
task than with the possible sleep in the watchdog timer code.  I can't
help but siding with the RedHat folks who currently ship a version of
the e1000 driver that fixes the mechanism used to sleep instead of the
watchdog_task approach.  Perhaps I missed the discussion of this, I'm
only finding the patch itself with google.

Thanks,
Shaw
