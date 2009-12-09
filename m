From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: Q: netdev: generate kobject uevent on network events.
Date: Wed, 9 Dec 2009 19:46:26 +0100
Message-ID: <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
References: <20091209170251.GA11650@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091209170251.GA11650@sig21.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 9, 2009 at 18:02, Johannes Stezenbach <js@sig21.net> wrote:
> about a year ago you posted a patch which allows to manage
> network hotplug via udev (or busybox mdev), which is useful
> for low-end embedded platforms that don't want to run ifplugd.
>
> http://article.gmane.org/gmane.linux.hotplug.devel/13386
>
> The patch still works with 2.6.32. =C2=A0Can it get merged or
> were there any issues with it? =C2=A0It seems the discussion
> just stopped and the patch was forgotten...

Can't, in some setups, these events happen at a rather high frequency?
I heard of people running many hundreds of ppp interfaces on a single
box acting as a DSL concentrator. They state to already have trouble
handling the amount of uevents generated on such boxes just for the
"add/remove" events of all the interfaces if something goes wrong with
the network. If we add more for state transitions, such events would
probably need to be rate-limited. In general, uevents/udev are not
really suitable for high-frequency events, and if such behavior can be
expected, we might better stick with the current netlink interface.

Thanks,
Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
