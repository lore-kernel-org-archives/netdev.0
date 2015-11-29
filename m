From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 21:26:40 +0100
Message-ID: <1448828800.2603.17.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:57965 "EHLO
	lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbbK2U0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 15:26:45 -0500
In-Reply-To: <565B4844.9020600@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On zo, 2015-11-29 at 19:47 +0100, Tilman Schmidt wrote:
> Btw I don't see a timer_list object in struct platform_device either.
> Nor in the embedded struct device.

I found two instances of struct timer_list, rather deep down struct
ser_cardstate:

struct ser_cardstate {
	struct platform_device dev {
		struct device dev {
			struct kobject kobj {
			#ifdef CONFIG_DEBUG_KOBJECT_RELEASE
				struct delayed_work release {
					struct timer_list timer;
				};
			#endif
			};
			struct dev_pm_info power {
			#ifdef CONFIG_PM
				struct timer_list suspend_timer;
			#endif
			};
		};
	};
};

(I only spotted these two and don't think there are others in the rest
of the exploded struct ser_cardstate.)

If the above is correct it would be nice to know the .config of the
kernel used by syzkaller.

Anyhow, without further details of the chain of events that triggered
this warning, I'm afraid it will be hard to determine which struct
timer_list is at the root of all this. (Ie, there's probably quite a bit
of code to wade through in order to determine that.)

Thanks,


Paul Bolle
