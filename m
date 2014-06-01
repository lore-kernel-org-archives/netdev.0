From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] ieee802154: use helper
 function to get rid of redundancy
Date: Sun, 1 Jun 2014 16:35:53 +0200
Message-ID: <20140601143550.GA13168@omega>
References: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
	<20140601072655.GA12277@omega>
	<20140601142317.GA19754@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Jean Sacren <sakiwit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140601142317.GA19754-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Jun 01, 2014 at 08:23:17AM -0600, Jean Sacren wrote:
> From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 01 Jun 2014 09:26:57 +0200
> 
> Hi Alex,
> 
> Thank you very much for the feedback.
> 
> > the at86rf230 driver supports several at86rf2xx chips. You split the
> > at86rf212_set_channel which is at86rf212 specific in two function which
> > are named at86rf230_foo.
> 
> I didn't "split" at86rf212_set_channel() in two functions. I spliced
> those two sections of code and made at86rf212_set_channel() far
> succinct and easy to read.
> 

yes, but this driver supports more than one chip and it's easier to read
if we have one channel_set function for each chip type. Note you also
named the specific channel_set function to a another at86rf230_foo
function which is at86rf212 specific only. Sorry that will confuse
all the people who will ever read this code.

There is a at86rf230_ops and at86rf212_ops struct. The channel_set
function it's much easier to have only one callback for each struct,
otherwise you have 4 different channel_set functions and nobody knows
for which at86rf2xx type that function is for.

> > Sorry, but I think we should not do this. One reason is that the code is
> > much easier to read when we have one channel_set callback for at86rf23x
> > and at86rf212 chips.
> 
> If you use one channel_set callback as before the change, how would you
> overcome the redundancy?
> 

There is no redundancy, sorry. There would be a redundancy if two
chiptypes like at86rf231 and at86rf212 needs some code of this callback
and you can do some codesharing, but you can't do that there.

- Alex

------------------------------------------------------------------------------
Time is money. Stop wasting it! Get your web API in 5 minutes.
www.restlet.com/download
http://p.sf.net/sfu/restlet
