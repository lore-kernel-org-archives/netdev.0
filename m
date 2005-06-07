From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 07 Jun 2005 08:38:24 -0400
Message-ID: <1118147904.6320.108.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
	 <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
	 <42A5284C.3060808@osdl.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <42A5284C.3060808@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-06-06 at 21:53 -0700, Stephen Hemminger wrote:
> I noticed that the tg3 driver copies packets less than a certain
> threshold to a new buffer, but e1000 always passes the big buffer up
> the stack. Could this be having an impact?

It is possible. Remember also the cost of IO these days is worse than a
cache miss in cycles as well as absolute time. So the e1000 maybe doing
more IO than the tg3. 

I think there is something fishy about the e1000 in general; From what i
just heard mentioned reading the emails is there's improvement if the rx
ring is replenished on a per packet basis instead of a batch at the end.
This somehow is not an issue with tg3. I think doing replenishing in
smaller batches like 5 packets at a time would also help.
That the tg3 doesnt need to have its rx ring sizes adjusted but the
e1000 gets better the lower the rx ring size is strange.

To the intel folks: shouldnt someone be investigating why this is so?

Fixing the effect with "lets lower the weight" or "wait, lets adjust it
at runtime" because we know it fixes our problem - sounds like a serious
bandaid to me. Lets find the cause and fix that instead.
Why is this issue happening with e1000? Thats what needs to be resolved.
So far some evidence seems to be suggesting that the tg3 uses less CPU.

cheers,
jamal
