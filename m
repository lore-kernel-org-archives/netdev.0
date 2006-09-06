From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Alternate WE-21 support (core API)
Date: Wed, 06 Sep 2006 16:43:54 -0500
Message-ID: <44FF411A.6010402@lwfinger.net>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156> <20060906205538.GA29767@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>, jt@hpl.hp.com,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:30848 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932090AbWIFVoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 17:44:03 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060906205538.GA29767@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Thu, Aug 31, 2006 at 04:00:05PM +0200, Johannes Berg wrote:
>> On Thu, 2006-08-31 at 06:51 -0700, Jouni Malinen wrote:
>>
>>> I don't know about the others, but long/short retry limits have users
>>> (e.g., Host AP driver) and these drivers are currently forced to use a
>>> hack to do this without this cleanup. Furthermore, this part does not
>>> add a new ioctl.
>> It does, however, add new parameters and things that'd need to be
>> translated in the compat layer later. Hence, even there, I'd prefer to
>> add them directly into nl80211. However, the compat code for that
>> shouldn't be that bad, so I can see that as a softer target :) But I
>> don't want to see new ioctls for sure.
> 
> OK, I think we all agree that there are good parts to Jean's WE-21
> patch.  Below I've made an attempt to separate the wheat from the chaff
> (or to cut the baby in half)...
> 
> Is this patch acceptable to the group?  Does it make things better?
> Or worse?  Did I leave-out anything that should still go in?  Did I
> take too much?
> 
> Let me know what you think...?

> + *
> + * The issue : wireless_send_event() is often called in interrupt context,
> + * while the Netlink layer can never be called in interrupt context.
> + * The fully formed RtNetlink events are queued, and then a tasklet is run
> + * to feed those to Netlink.
> + * The skb_queue is interrupt safe, and its lock is not held while calling
> + * Netlink, so there is no possibility of dealock.
                                              ^^^^^^^
You might as well fix the typo now. Otherwise, it looks OK to me. I've been running the original 
patch for several days with no problems. I don't think you removed anything essential.

Larry
